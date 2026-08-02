require 'rails_helper'

NO_COL = 0
TASKS_COL = 1
DEADLINES_COL = 2
REMAINING_TIMES_COL = 3

ALL_TASKS = 0

FIRST_TASK = 0
SECOND_TASK = 1
THIRD_TASK = 2

MAX_TASK_NAME_LENGTH = 255

RSpec.describe "Tasks", type: :system do
  before do
    visit root_path
  end

  describe "access the app" do
    context "as a guest" do
      it "is able to access the app", js: true do
        # ユーザーがタスクを持たない、かつ、タイマー停止状態の場合（総タスク数：0）。
        check_access

        # ユーザーがタスクを持つ、かつ、タイマー停止状態の場合（総タスク数：1）。
        task = create_task
        check_access(total_tasks_count: 1)

        # タイマー起動状態に設定する（作成したタスク名が存在し、かつ、そのタスクのタイマーがカウントダウンされていることを判定する）。
        click_timer_start(task[:task_name], task[:task_time])

        # ユーザーがタスクを持つ、かつ、タイマー起動状態の場合（総タスク数：1）。
        check_access(total_tasks_count: 1, timer_start: true)
      end
    end
  end

  describe "create a task" do
    context "as a guest" do
      context "under a timer stop condition" do
        it "is able to create a task", js: true do
          # タイマー停止状態下でタスクを作成する。
          create_task
        end

        it "is able to cancel creating a task", js: true do
          # タイマー停止状態下でタスクの作成をキャンセルする。
          create_task(cancel: true)
        end
      end

      context "under a timer start condition" do
        it "is able to create a task", js: true do
          # ユーザーがタスクを1つ以上持たなければタイマー起動状態にできないため、タスクを作成する。
          task = create_task

          # タイマー起動状態に設定する（作成したタスク名が存在し、かつ、そのタスクのタイマーがカウントダウンされていることを判定する）。
          click_timer_start(task[:task_name], task[:task_time])

          # タイマー起動状態下でタスクを作成する。
          create_task
        end

        it "is able to cancel creating a task", js: true do
          # ユーザーがタスクを1つ以上持たなければタイマー起動状態にできないため、タスクを作成する。
          task = create_task

          # タイマー起動状態に設定する（作成したタスク名が存在し、かつ、そのタスクのタイマーがカウントダウンされていることを判定する）。
          click_timer_start(task[:task_name], task[:task_time])

          # タイマー起動状態下でタスクの作成をキャンセルする。
          create_task(cancel: true)
        end
      end
    end
  end

  describe "update a task" do
    context "as a guest" do
      context "under a timer stop condition" do
        it "is able to update a task", js: true do
          # タスクを2つ作成し、1つ目のタスクを完了状態、2つ目のタスクを未完状態に設定する。
          2.times do
            create_task
          end
          set_task_done(task_order: 1)

          # タイマー停止状態下で、完了状態のタスクの編集をする。
          update_task(task_order: 1)

          # タイマー停止状態下で、未完状態のタスクの編集をする。
          update_task(task_order: 2)
        end

        it "is able to cancel updating a task", js: true do
          # タスクを2つ作成し、1つ目のタスクを完了状態、2つ目のタスクを未完状態に設定する。
          2.times do
            create_task
          end
          set_task_done(task_order: 1)

          # タイマー停止状態下で、完了状態のタスクの編集をキャンセルする。
          update_task(task_order: 1, cancel: true)

          # タイマー停止状態下で、未完状態のタスクの編集をキャンセルする。
          update_task(task_order: 2, cancel: true)
        end
      end

      context "under a timer start condition" do
        it "is able to update a task", js: true do
          # タスクを3つ作成し、以下の3種類のタスク状態を設定する。
          # 1つ目のタスク：未完状態、かつ、タイマー起動状態
          # 2つ目のタスク：未完状態、かつ、タイマー停止状態
          # 3つ目のタスク：完了状態、かつ、タイマー停止状態
          tasks = []
          3.times do
            tasks << create_task
          end
          set_task_done(task_order: 3)
          click_timer_start(tasks[FIRST_TASK][:task_name], tasks[FIRST_TASK][:task_time])

          # 完了状態、かつ、タイマー停止状態のタスクを編集する。
          update_task(task_order: 3)

          # 未完状態、かつ、タイマー停止状態のタスクを編集する。
          update_task(task_order: 2)

          # 未完状態、かつ、タイマー起動状態のタスクを編集する。
          update_task(task_order: 1, timer_start: true)
        end

        it "is able to cancel updating a task", js: true do
          # タスクを3つ作成し、以下の3種類のタスク状態を設定する。
          # 1つ目のタスク：未完状態、かつ、タイマー起動状態
          # 2つ目のタスク：未完状態、かつ、タイマー停止状態
          # 3つ目のタスク：完了状態、かつ、タイマー停止状態
          tasks = []
          3.times do
            tasks << create_task
          end
          set_task_done(task_order: 3)
          click_timer_start(tasks[FIRST_TASK][:task_name], tasks[FIRST_TASK][:task_time])

          # 完了状態、かつ、タイマー停止状態のタスクの編集をキャンセルする。
          update_task(task_order: 3, cancel: true)

          # 未完状態、かつ、タイマー停止状態のタスクの編集をキャンセルする。
          update_task(task_order: 2, cancel: true)

          # 未完状態、かつ、タイマー起動状態のタスクの編集をキャンセルする。
          update_task(task_order: 1, cancel: true, timer_start: true)
        end
      end
    end
  end

  describe "delete a task" do
    context "as a guest" do
      context "under a timer stop condition" do
        it "is able to delete a task", js: true do
          # タスクを2つ作成し、1つ目のタスクを完了状態、2つ目のタスクを未完状態に設定する。
          tasks = []
          2.times do
            tasks << create_task
          end
          set_task_done(task_order: 1)

          # タイマー停止状態下で、未完状態のタスクを削除する。
          delete_task(task_order: 2, task_name: tasks[SECOND_TASK][:task_name], task_time: tasks[SECOND_TASK][:task_time])

          # タイマー停止状態下で、完了状態のタスクを削除する。
          delete_task(task_order: 1, task_name: tasks[FIRST_TASK][:task_name], task_time: tasks[FIRST_TASK][:task_time])
        end
      end

      context "under a timer start condition" do
        it "is able to delete a task", js: true do
          # タスクを3つ作成し、以下の3種類のタスク状態を設定する。
          # 1つ目のタスク：未完状態、かつ、タイマー起動状態
          # 2つ目のタスク：未完状態、かつ、タイマー停止状態
          # 3つ目のタスク：完了状態、かつ、タイマー停止状態
          tasks = []
          3.times do
            tasks << create_task
          end
          set_task_done(task_order: 3)
          click_timer_start(tasks[FIRST_TASK][:task_name], tasks[FIRST_TASK][:task_time])

          # 完了状態、かつ、タイマー停止状態のタスクを削除する。
          delete_task(task_order: 3, task_name: tasks[THIRD_TASK][:task_name], task_time: tasks[THIRD_TASK][:task_time])

          # 未完状態、かつ、タイマー停止状態のタスクを削除する。
          delete_task(task_order: 2, task_name: tasks[SECOND_TASK][:task_name], task_time: tasks[SECOND_TASK][:task_time])

          # 未完状態、かつ、タイマー起動状態のタスクを削除する。
          delete_task(task_order: 1, task_name: tasks[FIRST_TASK][:task_name], task_time: tasks[FIRST_TASK][:task_time])

          # ユーザーがタスクを持たなくなったことで、タイマー停止状態に移行する。
          expect(page).to have_link "timer_start"
        end
      end
    end
  end

  describe "set a task done/undone" do
    context "as a guest" do
      context "under a timer stop condition" do
        it "is able to set a task done/undone", js: true do
          # タイマー停止状態下で未完状態のタスクを作成する。
          create_task
          check_set_task_undone(task_order: 1)

          # タイマー停止状態下でタスクを完了状態に設定する。
          set_task_done(task_order: 1)
          check_set_task_done(task_order: 1)

          # タイマー停止状態下でタスクを未完状態に設定する。
          set_task_undone(task_order: 1)
          check_set_task_undone(task_order: 1)
        end
      end

      context "under a timer start condition" do
        it "is able to set a task done/undone", js: true do
          # タスクを2つ作成し、以下の2種類のタスク状態を設定する。
          # 1つ目のタスク：タイマー起動状態
          # 2つ目のタスク：タイマー停止状態
          tasks = []
          2.times do
            tasks << create_task
          end
          click_timer_start(tasks[FIRST_TASK][:task_name], tasks[FIRST_TASK][:task_time])

          # 2種類の状態のタスクについて、タスクの状態を完了と未完了間で切り替えを行う。
          (1..2).each do |task_order|
            check_set_task_undone(task_order: task_order)
            set_task_done(task_order: task_order)
            check_set_task_done(task_order: task_order)
            set_task_undone(task_order: task_order)
            check_set_task_undone(task_order: task_order)
          end

          # 2つのタスクを完了状態に設定する。
          set_task_done(task_order: 1)
          set_task_done(task_order: 2)

          # 全てのタスクが完了状態に設定されたため、タイマー停止状態に移行する。
          expect(page).to have_link "timer_start"
        end
      end
    end
  end

  describe "set all tasks done/undone" do
    context "as a guest" do
      context "under a timer stop condition" do
        it "is able to set all tasks done/undone", js: true do
          # タイマー停止状態下で未完状態のタスクを2つ作成する。
          (1..2).each do |task_order|
            create_task
            check_set_task_undone(task_order: task_order)
          end

          # 全てのタスクは完了状態になっていないことを確認する。
          check_set_task_undone(task_order: ALL_TASKS)

          # 全てのタスクを完了状態に設定する。
          set_task_done(task_order: ALL_TASKS)
          check_set_task_done(task_order: ALL_TASKS)
          (1..2).each do |task_order|
            check_set_task_done(task_order: task_order)
          end

          # 全てのタスクを未完状態に設定する。
          set_task_undone(task_order: ALL_TASKS)
          check_set_task_undone(task_order: ALL_TASKS)
          (1..2).each do |task_order|
            check_set_task_undone(task_order: task_order)
          end
        end
      end

      context "under a timer start condition" do
        it "is able to set all tasks done/undone", js: true do
          # 未完状態のタスクを2つ作成し、タイマー起動状態に設定する。
          tasks = []
          (1..2).each do |task_order|
            tasks << create_task
            check_set_task_undone(task_order: task_order)
          end
          click_timer_start(tasks[FIRST_TASK][:task_name], tasks[FIRST_TASK][:task_time])

          # 全てのタスクは完了状態になっていないことを確認する。
          check_set_task_undone(task_order: ALL_TASKS)

          # 全てのタスクを完了状態に設定する。
          set_task_done(task_order: ALL_TASKS)
          check_set_task_done(task_order: ALL_TASKS)
          (1..2).each do |task_order|
            check_set_task_done(task_order: task_order)
          end

          # 全てのタスクが完了状態になったため、タイマー停止状態に移行する。
          expect(page).to have_link "timer_start"

          # 全てのタスクを未完状態に設定する。
          set_task_undone(task_order: ALL_TASKS)
          check_set_task_undone(task_order: ALL_TASKS)
          (1..2).each do |task_order|
            check_set_task_undone(task_order: task_order)
          end
        end
      end
    end
  end

  describe "set a timer start/stop" do
    context "as a guest" do
      it "is unable to set a timer start without task", js: true do
        # ユーザーがタスクを持たない場合、タイマー起動状態への移行しない。
        click_link "timer_start"
        expect(page).to have_link "timer_start"
      end

      it "is able to set a timer start/stop", js: true do
        # ユーザーがタスクを持つ場合、タイマー起動状態とタイマー停止状態間での切り替えする。
        task = create_task
        click_timer_start(task[:task_name], task[:task_time])
        click_timer_stop(task[:task_name])
      end
    end
  end

  describe "reset a timer" do
    context "as a guest" do
      context "under a timer stop condition" do
        it "is able to reset a timer", js: true do
          # タイマー一時停止状態下でタイマーリセットを設定する。
          task = create_task
          click_timer_start(task[:task_name], task[:task_time])
          click_timer_stop(task[:task_name])
          click_timer_reset(task[:task_name], task[:task_time])
        end
      end

      context "under a timer start condition" do
        it "is able to reset a timer", js: true do
          # タイマー起動状態下でタイマーリセットを設定する。
          task = create_task
          click_timer_start(task[:task_name], task[:task_time])
          click_timer_reset(task[:task_name], task[:task_time])
        end
      end
    end
  end
end

private
  def create_task(cancel: false)
    # タスク新規作成リンクを押下し、新規作成ページへ遷移する。
    click_link "add_circle"

    # タスク名とタスク時間を入力する。
    task_name = create_task_name
    task_time = rand(1..(24 * 60))
    fill_in "Task name", with: task_name
    fill_in "Task time", with: task_time

    # キャンセルフラグがtrueの場合。
    if cancel
      # タスク新規作成をキャンセルし、新規作成されていないことを確認する。
      click_link "cancel"
      check_cancel_task(task_name, task_time)

    # キャンセルフラグがfalseの場合。
    else
      # タスク新規作成し、新規作成されていることを確認する。
      click_button "Create Task"
      check_create_task(task_name, task_time)
    end

    # 新規作成またはキャンセルしたタスクの情報を戻り値に設定する。
    { task_name: task_name, task_time: task_time }
  end

  def update_task(task_order:, cancel: false, timer_start: false)
    max_retries = 3
    retries = 0
    begin
      # 指定したタスク番号に一致するタスクの編集リンクを押下する。
      all("table tr")[task_order].click_link "_edit"
    rescue Selenium::WebDriver::Error::StaleElementReferenceError, Selenium::WebDriver::Error::UnknownError
      retries += 1
      retry if retries <= max_retries
    end

    # 新しいタスク名とタスク時間を入力する。
    task_name = create_task_name
    task_time = rand(1..(24 * 60))
    fill_in "Task name", with: task_name
    fill_in "Task time", with: task_time

    # タイマー起動状態フラグがtrueの場合。
    if timer_start
      # 更新ボタンを押下し、新しいタスク名が存在し、かつ、
      # 新しいタスク時間が存在しない（タイマー起動状態のため、カウントダウンしているため一致しない）ことを確認する。
      click_button "Update Task"
      check_timer_start(task_name, task_time)

    # キャンセルフラグがtrueの場合。
    elsif cancel
      # タスクの編集をキャンセルし、編集後のタスク名とタスク時間が存在しないことを確認する。
      click_link "cancel"
      check_cancel_task(task_name, task_time)

    # 上記以外の場合。
    else
      # タスクの編集をし、編集後のタスク名とタスク時間が存在することを確認する。
      click_button "Update Task"
      check_update_task(task_name, task_time)
    end
  end

  def delete_task(task_order:, task_name:, task_time:)
    max_retries = 3
    retries = 0
    begin
      # 指定したタスク番号に一致するタスクの削除リンクを押下する。
      all("table tr")[task_order].click_link "_delete"
    rescue Selenium::WebDriver::Error::StaleElementReferenceError, Selenium::WebDriver::Error::UnknownError
      retries += 1
      retry if retries <= max_retries
    end
    # 削除したタスクが存在しないことを確認する。
    check_delete_task(task_name, task_time)
  end

  def set_task_done(task_order:)
    max_retries = 3
    retries = 0
    begin
      # 指定したタスク番号に一致するタスクのチェックボックスを押下し、タスクを完了状態にする。
      all("table tr")[task_order].click_link "check_box_outline_blank"
    rescue Selenium::WebDriver::Error::StaleElementReferenceError, Selenium::WebDriver::Error::UnknownError
      retries += 1
      retry if retries <= max_retries
    end
  end

  def set_task_undone(task_order:)
    max_retries = 3
    retries = 0
    begin
      # 指定したタスク番号に一致するタスクのチェックボックスを押下し、タスクを未完状態にする。
      all("table tr")[task_order].click_link "check_box"
    rescue Selenium::WebDriver::Error::StaleElementReferenceError, Selenium::WebDriver::Error::UnknownError
      retries += 1
      retry if retries <= max_retries
    end
  end

  def check_access(total_tasks_count: 0, timer_start: false)
    using_wait_time(15) do
      # 現在の日付と時刻を表示する時計の正規表現を定義し、それが存在するすることを確認する。
      clock_regexp = /\d{4}\/\d{1,2}\/\d{1,2}.*\d{1,2}:\d{2}:\d{2}/
      expect(page).to have_content(clock_regexp)

      # ユーザーが持つタスク一覧表が存在することを確認する。
      expect(page).to have_css ".task-list"
      expect(page).to have_content "No."
      expect(page).to have_content "Tasks"
      expect(page).to have_content "Deadlines"
      expect(page).to have_content "Remaining Times"

      # タスク新規作成リンクが存在することを確認する。
      expect(page).to have_css ".new-task"
      expect(page).to have_link "add_circle"

      # タイマーリセットリンクが存在することを確認する。
      expect(page).to have_link "timer_reset"

      # ユーザーがタスクを持つ場合。
      if total_tasks_count > 0
        task_order = 1

        # ユーザーのタスク一覧表に以下が存在することを確認する。
        # ヘッダーに全タスクを完了状態にするチェックボックスが存在することを確認する。
        expect(all("table tr")[ALL_TASKS]).to have_link "check_box_outline_blank"

        # タスク一覧表内にタスク番号、タスク名、タスク残り時間が存在することを確認する。
        expect(all("table tr td")[NO_COL]).to have_content "#{task_order}"
        expect(all("table tr td")[TASKS_COL]).to have_content(/\w{#{MAX_TASK_NAME_LENGTH}}/)
        expect(all("table tr td")[REMAINING_TIMES_COL]).to have_content(/\d{2}:\d{2}:\d{2} \/ \d{2}:\d{2}:\d{2}/)

        # タスク一覧表内に対象タスクを完了状態にするチェックボックス、編集リンク、削除リンクが存在することを確認する。
        expect(all("table tr")[task_order]).to have_link "check_box_outline_blank"
        expect(all("table tr")[task_order]).to have_link "_edit"
        expect(all("table tr")[task_order]).to have_link "_delete"

        # タイマー起動状態下の場合。
        if timer_start
          # タスク一覧表内のタスク締切時間が時計フォーマットで存在することを確認する。
          expect(all("table tr td")[DEADLINES_COL]).to have_content clock_regexp

          # タイマー停止用のリンクが存在すること（タイマー起動状態のため）。
          expect(page).to have_link "timer_stop"

        # タイマー停止状態下の場合。
        else
          # タスク一覧表内のタスク締切時間が「--:--」のフォーマットで存在することを確認する。
          expect(all("table tr td")[DEADLINES_COL]).to have_content "--:--"

          # タイマー起動用のリンクが存在すること（タイマー停止状態のため）。
          expect(page).to have_link "timer_start"
        end

      # ユーザーがタスクを持たない場合。
      else
        # 全タスクを完了状態にするチェックボックスが存在しないことを確認する。
        expect(page).to_not have_link "check_box_outline_blank"

        # タイマー起動用のリンクが存在すること（タイマー停止状態のため）。
        expect(page).to have_link "timer_start"
      end
    end
  end

  def check_create_task(task_name, task_time)
    max_retries = 3
    retries = 0
    begin
      # 新規作成したタスクの名前と時間が存在することを確認する。
      expect(page).to have_content task_name
      expect(page).to have_content convert_int_to_time(task_time)
    rescue Selenium::WebDriver::Error::UnknownError => e
      if e.message.include?("Node with given id does not belong to the document")
        retries += 1
        retry if retries <= max_retries
      end
    end
  end

  # タスク新規作成結果の確認はタスク編集結果の確認を兼ねる（両者とも対象タスクが存在することを確認する関数のため）。
  alias check_update_task check_create_task

  def check_delete_task(task_name, task_time)
    max_retries = 3
    retries = 0
    begin
      # 削除したタスクの名前と時間が存在しないことを確認する。
      expect(page).to_not have_content task_name
      expect(page).to_not have_content convert_int_to_time(task_time)
    rescue Selenium::WebDriver::Error::UnknownError => e
      if e.message.include?("Node with given id does not belong to the document")
        retries += 1
        retry if retries <= max_retries
      end
    end
  end

  # タスク削除結果の確認はタスク新規作成/編集キャンセルの結果を兼ねる（両者とも対象タスクが存在しないことを確認する関数のため）。
  alias check_cancel_task check_delete_task

  def check_set_task_done(task_order:)
    max_retries = 3
    retries = 0
    begin
      # 指定したタスク番号に一致するタスクが完了状態であることを確認する。
      expect(all("table tr")[task_order]).to have_link "check_box"
    rescue Selenium::WebDriver::Error::StaleElementReferenceError, Selenium::WebDriver::Error::UnknownError
      retries += 1
      retry if retries <= max_retries
    end
  end

  def check_set_task_undone(task_order:)
    max_retries = 3
    retries = 0
    begin
      # 指定したタスク番号に一致するタスクが未完状態であることを確認する。
      expect(all("table tr")[task_order]).to have_link "check_box_outline_blank"
    rescue Selenium::WebDriver::Error::StaleElementReferenceError, Selenium::WebDriver::Error::UnknownError
      retries += 1
      retry if retries <= max_retries
    end
  end

  def check_timer_start(task_name, task_time)
    using_wait_time(15) do
      max_retries = 3
      retries = 0
      begin
        # タイマー起動状態のタスク名が存在し、
        # タスク時間が存在しない（タイマー起動状態のため、カウントダウンしているため一致しない）ことを確認する。
        expect(page).to have_content task_name
        expect(page).to_not have_content convert_int_to_time(task_time)
      rescue Selenium::WebDriver::Error::UnknownError => e
        if e.message.include?("unknown error: unhandled inspector error")
          retries += 1
          retry if retries <= max_retries
        end
      end
    end
  end

  def check_timer_stop(task_name)
    # タスク番号1のタスク残り時間を取得する。
    converted_task_time = all("table tr td")[3].text

    # 処理待ちを行う。
    using_wait_time(15) do
      max_retries = 3
      retries = 0
      begin
        # タイマー一時停止状態のタスク名が存在し、
        # タスク時間が一時停止状態から変化していないことを確認する。
        expect(page).to have_content task_name
        expect(page).to have_content converted_task_time
      rescue Selenium::WebDriver::Error::UnknownError => e
        if e.message.include?("unknown error: unhandled inspector error")
          retries += 1
          retry if retries <= max_retries
        end
      end
    end
  end

  def check_timer_reset(task_name, task_time)
    using_wait_time(15) do
      max_retries = 3
      retries = 0
      begin
        # タスク名が存在し、タスク残り時間が初期状態で存在することを確認する。
        expect(page).to have_content task_name
        expect(page).to have_content convert_int_to_time(task_time)
      rescue Selenium::WebDriver::Error::UnknownError => e
        if e.message.include?("unknown error: unhandled inspector error")
          retries += 1
          retry if retries <= max_retries
        end
      end
    end
  end

  def click_timer_start(task_name, task_time)
    max_retries = 3
    retries = 0
    begin
      # タイマー起動用リンクをクリックする。
      click_link "timer_start"
    rescue Selenium::WebDriver::Error::UnknownError => e
      if e.message.include?("unknown error: unhandled inspector error")
        retries += 1
        retry if retries <= max_retries
      end
    end

    # タイマー起動状態であることを確認する。
    check_timer_start(task_name, task_time)
  end

  def click_timer_stop(task_name)
    max_retries = 3
    retries = 0
    begin
      # タイマー停止用リンクをクリックする。
      click_link "timer_stop"
    rescue Selenium::WebDriver::Error::UnknownError => e
      if e.message.include?("unknown error: unhandled inspector error")
        retries += 1
        retry if retries <= max_retries
      end
    end

    # タイマー一時停止状態であることを確認する。
    check_timer_stop(task_name)
  end

  def click_timer_reset(task_name, task_time)
    max_retries = 3
    retries = 0
    begin
      # タイマーリセット用リンクをクリックする。
      click_link "timer_reset"
    rescue Selenium::WebDriver::Error::UnknownError => e
      if e.message.include?("unknown error: unhandled inspector error")
        retries += 1
        retry if retries <= max_retries
      end
    end

    # タイマーがリセットされたことを確認する。
    check_timer_reset(task_name, task_time)
  end

  def create_task_name
    # 指定した文字長のランダムな英数字を生成し、タスク名とする。
    "#{SecureRandom.alphanumeric(MAX_TASK_NAME_LENGTH)}"
  end

  def convert_int_to_time(int)
    # ユーザーが入力したタスク時間（分）を時計フォーマットへ変換する。
    hour = (int / 60).to_s.rjust(2, "0")
    min = (int % 60).to_s.rjust(2, "0")
    "#{hour}:#{min}:00 / #{hour}:#{min}:00"
  end
