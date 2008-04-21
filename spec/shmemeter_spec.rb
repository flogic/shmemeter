require File.dirname(__FILE__) + '/spec_helper'

setup_rails_environment

describe 'delegation' do
  describe 'of a message to an object' do
    before :each do
      @class = Struct.new(:target) do
        delegate :forwarded_method, :to => :target
      end
      
      @target = stub('target')
      @object = @class.new(@target)
    end
    
    it 'should forward the message' do
      @target.expects(:forwarded_method)
      @object.forwarded_method
    end
    
    it 'should pass along an argument' do
      arg = stub('arg')
      @target.expects(:forwarded_method).with(arg)
      @object.forwarded_method(arg)
    end
    
    it 'should pass along multiple arguments' do
      args = Array.new(3) { stub('arg') }
      @target.expects(:forwarded_method).with(*args)
      @object.forwarded_method(*args)
    end
    
    it 'should return the value from the object' do
      val = stub('val')
      @target.stubs(:forwarded_method).returns(val)
      @object.forwarded_method.should == val
    end
  end
end
