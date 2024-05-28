from collections import OrderedDict
import typing as t

# ***************************************
# deep comparison between two objects
# ***************************************

def listeq(o1:t.List, o2:t.List) -> bool:
    """check that the list o1 is the same as o2, recursively if needed"""
    same = True
    # 1) check that they are the same length
    same = len(o1) == len(o2)
    if not same:
        return same
    # 2) check that items in both lists are the same type
    same = all( type(o1[i])==type(o2[i]) for i,el in enumerate(o1) )
    if not same:
        return same
    # 3) check the values, recursively if needed
    same = all( baseeq(o1[i], o2[i]) for i,el in enumerate(o1) )
    return same


def dicteq(o1:t.Dict, o2:t.Dict) -> bool:
    """check that the dict o1 is the same as the dict o2, recursively if needed"""
    same = True
    # before doing anything, sort both dicts
    o1 = OrderedDict( sorted(o1.items(), key=lambda x:x[0]) )
    o2 = OrderedDict( sorted(o2.items(), key=lambda x:x[0]) )
    # 1) check that there are the same number of keys
    same = len(o1.keys()) == len(o2.keys())
    if not same:
        return same
    # 2) check that the name of the keys in o1 and o2 are the same
    same = all( k1==k2 for k1,k2 in zip(o1.keys(), o2.keys()) )
    if not same:
        return same
    # 3) check that the types of the values for each key is the same in both dicts
    same = all( type(v1)==type(v2) for v1,v2 in zip(o1.values(), o2.values()) )
    if not same:
        return same
    # 4) check that the values are the same in both dicts
    same = all( baseeq(v1,v2) for v1, v2 in zip(o1.values(), o2.values()) )
    return same


def baseeq(o1:t.Any, o2:t.Any) -> bool:
    """
    check that o1 is the same as o2. this function 
    redirects to type-specific deep comparison functions
    """
    if not type(o1) == type(o2):
        return False
    if isinstance(o1, dict):
        return dicteq(o1, o2)
    elif isinstance(o1, list):
        return listeq(o1, o2)
    else:
        # print(">", o1, o2, "|",  type(o1), type(o2), "|", o1==o2)
        return o1 == o2
    return


if __name__ == "__main__":
    assert not listeq([1], ["1"])  # very basic type comparison

    assert not listeq([1,[2,3],3,4], [1,[2],3,4])  # recursively invalid value at position 2
   
    assert listeq([1, 2, [2,3], 3, 4, "a"], [1, 2, [2,3], 3, 4, "a"])  # recursively valid
    
    assert not dicteq({"z":1, "a": 2}, {"d": [1,2,4], "e": 2})  # key error

    assert not dicteq({"a": [1,2], "z": 1, "e": "__"}, {"a": 1, "b": 2})  # number of keys error

    assert dicteq({"z":1, "a": 2}, {"z":1, "a": 2})  # non-recursively valid

    assert not dicteq({"z":1, "a": "2"}, {"z":1, "a": 2})  # type error

    assert dicteq( {"z": 1, "a": { "a1": 2, "c1": [1, 2, {"z3": 1}]}}   # very recursively valid
                 , {"z": 1, "a": { "a1": 2, "c1": [1, 2, {"z3": 1}]}} )

    assert not dicteq( {"z": 1, "a": { "a1": 2, "c1": [1, 2, {"z3": 1}]}}   # very recursively invalid: different types
                     , {"z": 1, "a": { "a1": 2, "c1": [1, 2, {"z3": "1"}]}} )

    # now we check using baseeq as entry point
    assert not baseeq([1], ["1"])  # very basic type comparison

    assert not baseeq([1,[2,3],3,4], [1,[2],3,4])  # recursively invalid value at position 2
   
    assert baseeq([1, 2, [2,3], 3, 4, "a"], [1, 2, [2,3], 3, 4, "a"])  # recursively valid
    
    assert not baseeq({"z":1, "a": 2}, {"d": [1,2,4], "e": 2})  # key error

    assert not baseeq({"a": [1,2], "z": 1, "e": "__"}, {"a": 1, "b": 2})  # number of keys error

    assert baseeq({"z":1, "a": 2}, {"z":1, "a": 2})  # non-recursively valid

    assert not baseeq({"z":1, "a": "2"}, {"z":1, "a": 2})  # type error

    assert baseeq( {"z": 1, "a": { "a1": 2, "c1": [1, 2, {"z3": 1}]}}   # very recursively valid
                 , {"z": 1, "a": { "a1": 2, "c1": [1, 2, {"z3": 1}]}} )

    assert not baseeq( {"z": 1, "a": { "a1": 2, "c1": [1, 2, {"z3": 1}]}}   # very recursively invalid: different types
                     , {"z": 1, "a": { "a1": 2, "c1": [1, 2, {"z3": "1"}]}} )

