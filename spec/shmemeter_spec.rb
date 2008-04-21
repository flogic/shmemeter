require File.dirname(__FILE__) + '/spec_helper'

setup_rails_environment

describe 'delegation' do
  describe 'setup' do
    before :each do
      @class = Class.new
    end
    
    it 'should require a final hash argument' do
      lambda { @class.delegate }.should raise_error(ArgumentError)
    end
    
    it 'should accept a final hash argument with a target' do
      lambda { @class.delegate :to => :target }.should_not raise_error(ArgumentError)
    end
    
    it 'should require a target in the final hash argument' do
      lambda { @class.delegate :key => :value }.should raise_error(ArgumentError)
    end
    
    it 'should accept a method name' do
      lambda { @class.delegate :method, :to => :target }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept multiple method names' do
      lambda { @class.delegate :method1, :method2, :to => :target }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept no method name' do
      lambda { @class.delegate :to => :target }.should_not raise_error(ArgumentError)
    end
  end
  
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
  
  describe 'of messages to a different message on the object' do
    before :each do
      @class = Class.new
    end
    
    it 'should accept a method name' do
      lambda { @class.delegate :forwarded_method, :to => :target, :as => :target_method }.should_not raise_error(ArgumentError)
    end
    
    it 'should not accept multiple method names' do
      lambda { @class.delegate :method1, :method2, :to => :target, :as => :target_method }.should raise_error(ArgumentError)
    end
    
    it 'should require a method name' do
      lambda { @class.delegate :to => :target, :as => :target_method }.should raise_error(ArgumentError)
    end
  end
  
  describe 'of a message to a different message on an object' do
    before :each do
      @class = Struct.new(:target) do
        delegate :forwarded_method, :to => :target, :as => :target_method
      end
      
      @target = stub('target')
      @object = @class.new(@target)
    end
    
    it 'should forward the message' do
      @target.expects(:target_method)
      @object.forwarded_method
    end
    
    it 'should pass along an argument' do
      arg = stub('arg')
      @target.expects(:target_method).with(arg)
      @object.forwarded_method(arg)
    end
    
    it 'should pass along multiple arguments' do
      args = Array.new(3) { stub('arg') }
      @target.expects(:target_method).with(*args)
      @object.forwarded_method(*args)
    end
    
    it 'should return the value from the object' do
      val = stub('val')
      @target.stubs(:target_method).returns(val)
      @object.forwarded_method.should == val
    end
  end
end
