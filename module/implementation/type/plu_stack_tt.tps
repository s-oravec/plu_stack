create or replace type plu_stack_tt as object
(
    items plu_stack_varray_tt,

    constructor function plu_stack_tt return self as result,

    member procedure push
    (
        self in out nocopy plu_stack_tt,
        item in plu_stack_type_tt /*#base*/
    ),

    member function pop(self in out nocopy plu_stack_tt) return plu_stack_type_tt, /*#base*/

    member procedure pop(self in out nocopy plu_stack_tt),

    member function peek return plu_stack_type_tt, /*#base*/

-- 1 true, 0 false
    member function is_empty return integer
)
/
