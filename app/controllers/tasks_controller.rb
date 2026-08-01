class TasksController < ApplicationController
  before_action :set_user
  before_action :set_tasks, only: %i[ index destroy timer reset_timer done done_all ]
  before_action :set_task, only: %i[ edit update destroy done ]

  def index
    # ユーザーが現在取り組んでいるタスクの番号（1以上の整数）を取得し、取り組んでいるタスクあるならばタイマー起動中と判定する。
    if @user.working_task_order > 0
      # タイマー起動中は、現在取り組んでいるタスクについて、現在までのタスク取り組み時間を算出、更新する。
      set_elapsed_task_time(get_working_task)
    end
  end

  def new
    # 新規作成するタスクの通し番号は、ユーザーが持つ総タスク数に1加えた数（1以上の整数）とする。
    task_order = @user.total_tasks_count + 1
    @task = Task.new(
      user_id: @user.id, task_order: task_order, done_flag: false, timer_flag: false,
      timer_started_at: Time.now, timer_stopped_at: Time.now, elapsed_task_time: 0)
  end

  def create
    Task.transaction do
      # タスクを新規作成する際は、タスク時間を分から秒に変換してデータベースへ保存する。
      @task = Task.new(task_params)
      @task.task_time *= 60

      # ユーザーが持つ総タスク数をインクリメントする。
      @user.increment(:total_tasks_count, 1)

      respond_to do |format|
        if @user.save && @task.save
          format.html { redirect_to tasks_path }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end
  end

  def edit
    # タスクを編集する際は、タスク時間を秒から分に変換して表示する。
    @task.task_time /= 60
  end

  def update
    # タスクを更新する際は、タスク時間を分から秒に変換した値でデータベースを更新する。
    respond_to do |format|
      if @task.update(task_params) && @task.update(task_time: @task.task_time * 60)
        format.html { redirect_to tasks_path }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    Task.transaction do
      # 削除対象のタスクのタスクの番号（1以上の整数）を取得し、記憶する。
      destroy_task_order = @task.task_order

      # 削除に伴い、ユーザーが持つ完了タスク数と総タスク数をデクリメントする。
      @user.decrement!(:done_tasks_count, 1) if @task.done_flag
      @user.decrement!(:total_tasks_count, 1)

      # 現在取り組んでいるタスクがある（タイマー起動状態である）場合、一旦タイマー停止状態にして後続の処理を行う。。
      set_timer_stop(get_working_task)

      # 対象のタスクを削除し、タスク番号の前詰め処理を行う。
      @task.destroy!
      @tasks.where("task_order > ?", destroy_task_order).update_all("task_order = task_order - 1")

      # 削除に伴い、ユーザーが未完タスクを持たなくなった場合。
      if @user.total_tasks_count == 0 || @user.total_tasks_count == @user.done_tasks_count
        # ユーザーが現在取り組んでいるタスクをなしに設定する。
        reset_working_task

      # ユーザーが未完タスクをまだ持っている場合。
      else
        # ユーザーが現在取り組んでいるタスクを持っている場合（タイマー起動状態であった場合）。
        if @user.working_task_order > 0
          # 未完タスクの内で最も番号の若いタスクのタイマーを起動状態にする。
          set_timer_start(get_next_task)
        end

        # ユーザーが現在取り組んでいるタスクを持っていない場合（タイマー停止状態であった場合）。
        # 処理なし。
      end
    end

    respond_to do |format|
      format.html { redirect_to tasks_path }
    end
  end

  def timer
    Task.transaction do
      # ユーザーが未完タスクを持っていない場合。
      if @user.total_tasks_count == 0 || @user.total_tasks_count == @user.done_tasks_count
      # 処理なし。

      # ユーザーが未完タスクを持っている場合。
      else
        # ユーザーが現在取り組んでいるタスクを持っている場合（タイマー起動状態であった場合）。
        if @user.working_task_order > 0
          # ユーザーが現在取り組んでいるタスクのタイマーを停止状態にし、取り組んでいるタスクをなしに設定する。
          set_timer_stop(get_working_task)
          reset_working_task

        # ユーザーが現在取り組んでいるタスクを持っていない場合（タイマー停止状態であった場合）。
        else
          # 未完タスクの内で最も番号の若いタスクのタイマーを起動状態にする。
          set_timer_start(get_next_task)
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to tasks_path }
    end
  end

  def reset_timer
    Task.transaction do
      # ユーザーが持つ全てのタスクのタイマーについて、カウントダウンをリセットするとともに、タイマー停止状態にする。
      @tasks.update_all(timer_flag: false, timer_started_at: Time.now, timer_stopped_at: Time.now, elapsed_task_time: 0)
      reset_working_task
    end

    respond_to do |format|
      format.html { redirect_to tasks_path }
    end
  end

  def done
    Task.transaction do
      # タスクの状態を完了と未完了間で切り替えを行う。
      if @task.done_flag
        unset_done_flag(@task)
      else
        set_done_flag(@task)
      end

      # 現在取り組んでいるタスクがある（タイマー起動状態である）場合、一旦タイマー停止状態にする。
      set_timer_stop(get_working_task)

      # ユーザーが未完タスクを持っていない場合。
      if @user.total_tasks_count == 0 || @user.total_tasks_count == @user.done_tasks_count
        # 現在取り組んでいるタスクをなしに設定する。
        reset_working_task

      # ユーザーが未完タスクをまだ持っている場合。
      else
        # ユーザーが現在取り組んでいるタスクを持っている場合（タイマー起動状態であった場合）。
        if @user.working_task_order > 0
          # 未完タスクの内で最も番号の若いタスクのタイマーを起動状態にする。
          set_timer_start(get_next_task)
        end

        # ユーザーが現在取り組んでいるタスクを持っていない場合（タイマー停止状態であった場合）。
        # 処理なし。
      end
    end

    respond_to do |format|
      format.html { redirect_to tasks_path }
    end
  end

  def done_all
    Task.transaction do
      # ユーザーがタスクを1つ以上持っている場合。
      if @user.total_tasks_count > 0
        # ユーザー未完タスクを持っていない場合。
        if @user.total_tasks_count == @user.done_tasks_count
          # ユーザーの全てのタスクを未完状態に設定する。
          @tasks.update_all(done_flag: false)
          @user.update(done_tasks_count: 0)

        # ユーザーが未完タスクをまだ持っている場合。
        else
          # ユーザーが現在取り組んでいるタスクを持っている場合（タイマー起動状態であった場合）。
          if @user.working_task_order > 0
            # 現在取り組んでいるタスクのタイマーを停止状態にし、取り組んでいるタスクをなしに設定する。
            set_timer_stop(get_working_task)
            reset_working_task
          end

          # ユーザーの全てのタスクを完了状態に設定する。
          @tasks.each do |task|
            next if task.done_flag
            set_done_flag(task)
          end
        end
      end

      # ユーザーがタスクを持っていない場合。
      # 処理なし。
    end

    respond_to do |format|
      format.html { redirect_to tasks_path }
    end
  end

  private
    def set_user
      @user = current_or_guest_user
    end

    def set_tasks
      @tasks = @user.tasks || @user.none
    end

    def set_task
      @task = Task.find(params[:id])
    end

    def set_timer_start(task)
      set_working_task(task)
      task.update(timer_flag: true, timer_started_at: Time.now) if task
    end

    def set_timer_stop(task)
      task.update(timer_flag: false, timer_stopped_at: Time.now) if task
      set_elapsed_task_time(task)
    end

    def set_elapsed_task_time(task)
      # 対象タスクの存在を判定する。
      if task
        # タイマー起動時刻とタイマー停止時刻の差分を求める。
        timer_diff = (task.timer_stopped_at - task.timer_started_at).to_i

        # タイマーの状態を判定（タイマー起動中：差分が0未満の場合、タイマー停止中：差分が0以上の場合）し、
        # ユーザーがタスクに取り組んでいる（いた）時間を算出し、累計時間に加算する。
        if timer_diff < 0
          # タイマー起動中
          task.increment!(:elapsed_task_time, (Time.now - task.timer_started_at).to_i)
          task.update(timer_started_at: Time.now)
        else
          # タイマー停止中
          task.increment!(:elapsed_task_time, timer_diff)
        end
      end
    end

    def set_done_flag(task)
      task.update(done_flag: true)
      @user.increment!(:done_tasks_count, 1)
    end

    def unset_done_flag(task)
      task.update(done_flag: false)
      @user.decrement!(:done_tasks_count, 1)
    end

    def set_working_task(task)
      @user.update(working_task_order: task.task_order)
    end

    def reset_working_task
      @user.update(working_task_order: 0)
    end

    def get_working_task
      @tasks.find_by(task_order: @user.working_task_order)
    end

    def get_next_task
      @tasks.where(done_flag: false).order(:task_order).first
    end

    def task_params
      params.require(:task).permit(
        :user_id, :task_order, :task_name, :task_time, :done_flag, :timer_flag, :timer_started_at, :timer_stopped_at, :elapsed_task_time)
    end
end
