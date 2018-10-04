# This is a unit test for the AWS Train plugin
# Its job is to verify that the Connection class is setup correctly.

# Include our test harness
require_relative '../helper'

# Load the class under test, the Connection definition.
require 'train-aws/connection'

# Because InSpec is a Spec-style test suite, we're going to use MiniTest::Spec
# here, for familiar look and feel. However, this isn't InSpec (or RSpec) code.
describe TrainPlugins::Aws::Connection do

  # When writing tests, you can use `let` to create variables that you
  # can reference easily.

  # This is a long name.  Shorten it for clarity.
  let(:connection_class) { TrainPlugins::Aws::Connection }

  # Some tests through here use minitest Expectations, which attach to all
  # Objects, and begin with 'must' (positive) or 'wont' (negative)
  # See https://ruby-doc.org/stdlib-2.1.0/libdoc/minitest/rdoc/MiniTest/Expectations.html

  it "should inherit from the Train Connection base" do
    # For Class, '<' means 'is a descendant of'
    (connection_class < Train::Plugins::Transport::BaseConnection).must_equal(true)
  end

  # Since this is an API-type connection, we MUST NOT implement these three.
  [
    :file_via_connection,
    :run_command_via_connection,
    :local?,
  ].each do |method_name|
    it "should NOT provide a #{method_name}() method" do
      # false passed to instance_methods says 'don't use inheritance'
      connection_class.instance_methods(false).wont_include(method_name)
    end
  end

  # As an API-type plugin, we get to decide how to talk to our API.
  # We use teh aws-sdk, which provides two metphors for accessing AWS objects:
  # a client-based approach (which focuses on explicit API calls) and a
  # resource-based approach  (which allows you to ask for all EC2 instances,
  # and the SDK will handle pagination, etc.)
  [
    :aws_client,
    :aws_resource,
  ].each do |method_name|
    it "should provide a #{method_name}() method" do
      # false passed to instance_methods says 'don't use inheritance'
      connection_class.instance_methods(false).must_include(method_name)
    end
  end

  # Ensure Train knows this is not local.
  it "should declare itself as a non-local transport" do
    connection_class.new(Hash.new).local?.must_equal(false)
  end
end
