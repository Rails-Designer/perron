require "test_helper"

class Perron::ConciergeControllerTest < ActionController::TestCase
  setup do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      post "/perron/run_command", to: "perron/concierge#run_command"
      root to: "perron/concierge#show"
    end

    @request.remote_addr = "127.0.0.1"
    @recorded_command_arguments = []
  end

  test "runs the collection command with fixed arguments" do
    process_run_command(action_key: "collection")

    assert_equal [%w[bin/rails generate content Post]], @recorded_command_arguments
    assert_redirected_to root_path
  end

  test "runs the new content command with fixed arguments" do
    process_run_command(action_key: "new_content")

    assert_equal [%w[bin/rails generate content Post --new]], @recorded_command_arguments
    assert_redirected_to root_path
  end

  test "rejects an unknown action key" do
    process_run_command(action_key: "unknown")

    assert_response :unprocessable_entity
    assert_empty @recorded_command_arguments
  end

  test "rejects a missing action key" do
    process_run_command

    assert_response :unprocessable_entity
    assert_empty @recorded_command_arguments
  end

  test "ignores a command parameter containing shell metacharacters" do
    process_run_command(
      action_key: "collection",
      command: "bin/rails generate content Post; touch /tmp/perron-command-injection"
    )

    assert_equal [%w[bin/rails generate content Post]], @recorded_command_arguments
  end

  test "rejects a non-local request" do
    @request.remote_addr = "203.0.113.10"

    process_run_command(action_key: "collection")

    assert_response :forbidden
    assert_empty @recorded_command_arguments
  end

  private

  def process_run_command(parameters = {})
    @controller.stub(:execute_command, ->(command_arguments) { @recorded_command_arguments << command_arguments }) do
      post :run_command, params: parameters
    end
  end
end
