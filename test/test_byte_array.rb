#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('..', __FILE__)
require 'helper'

class TestByteArray < Test::Unit::TestCase
  def test_order
    [
      [(1..100).to_a, :fixnum],
      [('aa'..'zz').to_a, :string],
    ].each do |pair|
      arr, type = pair
      assert_equal arr,
        arr.reverse.map { |e| HBase::ByteArray.new(e) }.sort.map { |ba|
          HBase::Util.from_bytes type, ba.java
        }
    end
  end

  def test_stopkey_bytes_for_prefix
    assert_equal HBase::ByteArray.new("hellp"),
      HBase::ByteArray.new( HBase::ByteArray.new("hello").stopkey_bytes_for_prefix )
    assert_equal HBase::ByteArray.new("BLUF"),
      HBase::ByteArray.new( HBase::ByteArray.new("BLUE").stopkey_bytes_for_prefix )
    assert_nil HBase::ByteArray.new([127, 127, 127].to_java(Java::byte)).stopkey_bytes_for_prefix
    assert_equal HBase::ByteArray.new([126, 127].to_java(Java::byte)),
      HBase::ByteArray.new(
        HBase::ByteArray.new([126, 126, 127, 127, 127, 127].to_java(Java::byte)).stopkey_bytes_for_prefix
      )
  end

  def test_as_hash_key
    hash = {
      HBase::ByteArray.new("Hello") => 1,
      HBase::ByteArray.new("World") => 2
    }
    assert_equal 1, hash[ HBase::ByteArray.new("Hello") ]
    assert_equal 2, hash[ HBase::ByteArray.new("World".to_java_bytes) ]
  end
end
