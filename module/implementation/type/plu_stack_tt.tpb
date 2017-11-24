create or replace type body plu_stack_tt as

    ---------------------------------------------------------------------------- 
    constructor function plu_stack_tt return self as result is
    begin
        self.items := plu_stack_varray_tt();
        return;
    end;

    ---------------------------------------------------------------------------- 
    member procedure push
    (
        self in out nocopy plu_stack_tt,
        item in plu_stack_type_tt /*#base*/
    ) is
    begin
        self.items.extend();
        self.items(self.items.count) := item;
    end;

    ---------------------------------------------------------------------------- 
    member function pop(self in out nocopy plu_stack_tt) return plu_stack_type_tt /*#base*/
     is
        l_result plu_stack_type_tt;
    begin
        l_result := self.items(self.items.count);
        self.items.trim;
        return l_result;
    end;

    ---------------------------------------------------------------------------- 
    member procedure pop(self in out nocopy plu_stack_tt) is
        l_dummy plu_stack_type_tt;
    begin
        l_dummy := self.pop();
    end;

    ----------------------------------------------------------------------------
    member function peek return plu_stack_type_tt /*#base*/
     is
    begin
        return(self.items(self.items.count));
    end;

    ----------------------------------------------------------------------------
    member function is_empty return integer is
    begin
        if self.items.count = 0 then
            return 1;
        else
            return 0;
        end if;
    end;

end;
/
