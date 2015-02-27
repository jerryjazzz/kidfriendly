
{ObjectUtil, Place} = require('kfly_server')
{assert, expect} = require('chai')

describe 'ObjectUtil', ->
  describe '.isObject', ->
    it 'works', ->
      class T

      assert(ObjectUtil.isObject({}))
      assert(ObjectUtil.isObject(new T()))
      assert(not ObjectUtil.isObject(null))
      assert(not ObjectUtil.isObject(false))
      assert(not ObjectUtil.isObject("hello"))

  describe '.merge', ->
    it 'works', ->
      merge = ObjectUtil.merge

      expect(merge({}, {a:1})).deep.equals({a:1})
      expect(merge({a:1}, {})).deep.equals({a:1})
      expect(merge({a:1}, {b:2})).deep.equals({a:1, b:2})
      expect(merge({a:1}, {a:2})).deep.equals({a:2})
      expect(merge({a:{b:{c:1}}}, {a:{b:{c:2}}})).deep.equals({a:{b:{c:2}}})
      expect(merge({a:{b:{c:1}}}, {a:{b:{d:2}}})).deep.equals({a:{b:{c:1, d:2}}})
