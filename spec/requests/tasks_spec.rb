require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  describe "GET /" do
    context "as a guest user" do
      it "responds successfully" do
        get root_path
        expect(response).to be_successful
        expect(response).to have_http_status "200"
      end
    end
  end

  describe "GET /tasks/index" do
    context "as a guest user" do
      it "responds successfully" do
        get tasks_path
        expect(response).to be_successful
        expect(response).to have_http_status "200"
      end
    end
  end

  describe "GET /tasks/new" do
    context "as a guest user" do
      it "responds successfully" do
        get new_task_path
        expect(response).to be_successful
        expect(response).to have_http_status "200"
      end
    end
  end

  describe "POST /tasks/create" do
    context "as a guest user" do
      context "with valid attributes" do
        it "creates a task and redirects to tasks_path" do
          @user = FactoryBot.create(:user)
          task_params = FactoryBot.attributes_for(:task, user_id: @user.id)

          expect {
            post tasks_path, params: { task: task_params }
          }.to change(@user.tasks, :count).by(1)
          expect(response).to redirect_to tasks_path
          expect(response).to have_http_status "302"
        end
      end

      context "with invalid attributes" do
        it "does not create a task" do
          @user = FactoryBot.create(:user)
          task_params = FactoryBot.attributes_for(:task, user_id: @user.id, task_name: nil)

          expect {
            post tasks_path, params: { task: task_params }
          }.to_not change(@user.tasks, :count)
          expect(response).to have_http_status "422"
        end
      end
    end
  end

  describe "GET /tasks/edit" do
    context "as a guest user" do
      it "responds successfully" do
        @user = FactoryBot.create(:user)
        @task = FactoryBot.create(:task, user_id: @user.id)

        get edit_task_path(@task.id)
        expect(response).to be_successful
        expect(response).to have_http_status "200"
      end
    end
  end

  describe "PATCH /tasks/update" do
    context "as a guest user" do
      context "with valid attributes" do
        it "updates a task and redirects to tasks_path" do
          @user = FactoryBot.create(:user)
          @task = FactoryBot.create(:task, user_id: @user.id)
          task_params = FactoryBot.attributes_for(:task, task_name: "Successfully updated")

          patch task_path(@task.id), params: { id: @task.id, task: task_params }
          expect(@task.reload.task_name).to eq "Successfully updated"
          expect(response).to redirect_to tasks_path
          expect(response).to have_http_status "302"
        end
      end

      context "with invalid attributes" do
        it "does not update a task" do
          @user = FactoryBot.create(:user)
          @task = FactoryBot.create(:task, user_id: @user.id)
          task_params = FactoryBot.attributes_for(:task, task_name: nil)

          patch task_path(@task.id), params: { id: @task.id, task: task_params }
          expect(response).to have_http_status "422"
        end
      end
    end
  end

  describe "GET /tasks/destroy" do
    context "as a guest user" do
      context "with valid attributes" do
        it "deletes a task and redirects to tasks_path" do
          @user = FactoryBot.create(:user)
          @task = FactoryBot.create(:task, user_id: @user.id)

          expect {
            delete task_path(@task.id), params: { id: @task.id }
          }.to change(@user.tasks, :count).by(-1)
          expect(response).to redirect_to tasks_path
          expect(response).to have_http_status "302"
        end
      end
    end
  end

  describe "GET /tasks/timer" do
    context "as a guest user" do
      it "redirects to tasks_path" do
        get timer_tasks_path
        expect(response).to redirect_to tasks_path
        expect(response).to have_http_status "302"
      end
    end
  end

  describe "GET /tasks/reset_timer" do
    context "as a guest user" do
      it "redirects to tasks_path" do
        get reset_timer_tasks_path
        expect(response).to redirect_to tasks_path
        expect(response).to have_http_status "302"
      end
    end
  end

  describe "GET /tasks/done" do
    context "as a guest user" do
      it "redirects to tasks_path" do
        @task = FactoryBot.create(:task)

        get done_task_path(@task.id)
        expect(response).to redirect_to tasks_path
        expect(response).to have_http_status "302"
      end
    end
  end

  describe "GET /tasks/done_all" do
    context "as a guest user" do
      it "redirects to tasks_path" do
        get done_all_tasks_path
        expect(response).to redirect_to tasks_path
        expect(response).to have_http_status "302"
      end
    end
  end
end
