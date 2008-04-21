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
  
  describe 'of a message to an arbitrarily-deeply-nested object' do
    before :each do
      @class = Struct.new(:down) do
        delegate :forwarded_method, :to => 'down.deep.target'
      end
      
      @target = stub('target')
      deep = Struct.new(:target).new(@target)
      down = Struct.new(:deep).new(deep)
      @object = @class.new(down)
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
  
  describe 'of multiple messages to an object' do
    before :each do
      @class = Struct.new(:target) do
        delegate :forwarded_method, :other_method, :to => :target
      end
      
      @target = stub('target')
      @object = @class.new(@target)
    end
    
    it 'should forward the first message' do
      @target.expects(:forwarded_method)
      @object.forwarded_method
    end
    
    it 'should forward the second message' do
      @target.expects(:other_method)
      @object.other_method
    end
    
    it 'should pass along an argument to the first method' do
      arg = stub('arg')
      @target.expects(:forwarded_method).with(arg)
      @object.forwarded_method(arg)
    end
    
    it 'should pass along an argument to the second method' do
      arg = stub('arg')
      @target.expects(:other_method).with(arg)
      @object.other_method(arg)
    end
    
    it 'should pass along multiple arguments to the first method' do
      args = Array.new(3) { stub('arg') }
      @target.expects(:forwarded_method).with(*args)
      @object.forwarded_method(*args)
    end
    
    it 'should pass along multiple arguments to the second method' do
      args = Array.new(3) { stub('arg') }
      @target.expects(:other_method).with(*args)
      @object.other_method(*args)
    end
    
    it 'should return the value from the object for the first method' do
      val = stub('val')
      @target.stubs(:forwarded_method).returns(val)
      @object.forwarded_method.should == val
    end
    
    it 'should return the value from the object for the second method' do
      val = stub('val')
      @target.stubs(:other_method).returns(val)
      @object.other_method.should == val
    end
  end
end
