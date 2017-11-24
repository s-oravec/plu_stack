create or replace package body plu_stack_impl as

    ----------------------------------------------------------------------------  
    function valid_template_type(a_template_type in plu_stack.object_name_type) return plu_stack.object_name_type is
        l_result plu_stack.object_name_type;
    begin
        -- clean whitespace
        l_result := regexp_replace(a_template_type, '[[:space:]]+', '');
        if not regexp_like(l_result, TEMPLATE_TYPE_REGEX, 'i') then
            raise_application_error(-20000, 'Invalid Template Type: "' || a_template_type || '".');
        else
            return l_result;
        end if;
    end;

    ----------------------------------------------------------------------------  
    function get_type_base(a_template_type in plu_stack.object_name_type) return plu_stack.object_name_type is
    begin
        return regexp_substr(a_template_type, TEMPLATE_TYPE_REGEX, 1, 1, 'i', 1);
    end;

    ----------------------------------------------------------------------------  
    function get_prefix_from_template_type(a_template_type in plu_stack.object_name_type) return plu_stack.object_name_type is
    begin
        return replace(regexp_substr(a_template_type, TEMPLATE_TYPE_REGEX, 1, 1, 'i', 1), '.', '_');
    end;

    ----------------------------------------------------------------------------  
    function get_template
    (
        a_object_type in plu_stack.object_name_type,
        a_object_name in plu_stack.object_name_type
    ) return clob is
        l_result clob;
        l_text   varchar2(32767);
        l_key    varchar2(255);
    begin
        -- for each source line
        for line in (select case line
                                when 1 then
                                -- prefix 1st line 
                                 'create or replace ' || text
                                else
                                 text
                            end as text
                       from user_source
                      where name = upper(a_object_name)
                        and type = upper(a_object_type)
                      order by line) loop
            l_text := line.text;
            -- if line contains plu_stack - replace template object names with instance object name variables
            -- iterate bbackwards, as /*# base */ are lexicographically greater
            if regexp_like(l_text, TEMPLATE_PREFIX, 'i') then
                l_key := g_impl_to_tmpl_map.last;
                while l_key is not null loop
                    l_text := replace(l_text, l_key, '${' || g_impl_to_tmpl_map(l_key) || '}');
                    l_key  := g_impl_to_tmpl_map.prior(l_key);
                end loop;
            end if;
            -- append to result
            l_result := l_result || l_text;
        end loop;
        --
        return l_result;
        --
    end;

    ----------------------------------------------------------------------------  
    function get_ddl_scripts
    (
        a_template_type      in plu_stack.object_name_type,
        a_object_name_prefix in plu_stack.object_name_type default null
    ) return plu_stack.ddl_scripts_type is
        l_result plu_stack.ddl_scripts_type := new plu_stack.ddl_scripts_type();
    begin
        l_result.extend(g_ident_to_template_obj.count);
        for l_script_identifier in 1 .. g_ident_to_template_obj.count loop
            l_result(l_script_identifier) := get_ddl_script(a_template_type, l_script_identifier, a_object_name_prefix);
        end loop;
        return l_result;
    end;

    ----------------------------------------------------------------------------  
    function get_tePLSQL_variable_map
    (
        a_object_name_prefix in plu_stack.object_name_type,
        a_template_type      in plu_stack.object_name_type
    ) return teplsql.t_assoc_array is
        l_result teplsql.t_assoc_array;
    begin
        -- prepare tePLSQL variables map
        l_result(TEMPLATE_PREFIX || '_varray') := a_object_name_prefix || '_varray';
        l_result(TEMPLATE_PREFIX || '_stack') := a_object_name_prefix || '_stack';
        l_result(TEMPLATE_PREFIX || '_template_type') := a_template_type;
        l_result(TEMPLATE_PREFIX || '_template_type_base') := get_type_base(a_template_type);
        --
        return l_result;
        --
    end;

    ----------------------------------------------------------------------------
    function get_ddl_script
    (
        a_template_type      in plu_stack.object_name_type,
        a_script_identifier  in plu_stack.script_identifier_type,
        a_object_name_prefix in plu_stack.object_name_type default null
    ) return clob is
        l_object_name_prefix plu_stack.object_name_type;
        l_template_type      plu_stack.object_name_type;
    begin
        -- clean and validate
        l_template_type := valid_template_type(a_template_type);
        -- if prefix not set set it to template type base
        l_object_name_prefix := nvl(a_object_name_prefix, get_prefix_from_template_type(l_template_type));
        -- prepare tePLSQL variable map and  
        -- convert template implementation object into template and render using tePLSQL
        return teplsql.render(get_tePLSQL_variable_map(l_object_name_prefix, l_template_type),
                              get_template(g_ident_to_template_obj(a_script_identifier).object_type,
                                           g_ident_to_template_obj(a_script_identifier).object_name));
    end;

    ----------------------------------------------------------------------------  
    procedure register_template_impl_obj
    (
        a_script_identifier in plu_stack.script_identifier_type,
        a_object_type       in plu_stack.object_name_type,
        a_object_name       in plu_stack.object_name_type
    ) is
        l_rec object_type_name_rec_type;
    begin
        l_rec.object_type := a_object_type;
        l_rec.object_name := a_object_name;
        g_ident_to_template_obj(a_script_identifier) := l_rec;
    end;

    ----------------------------------------------------------------------------  
    procedure init is
    begin
        -- create mapping from template implementation object names to tePLSQL template variable names
        g_impl_to_tmpl_map(TEMPLATE_PREFIX || '_varray_tt') := TEMPLATE_PREFIX || '_varray';
        g_impl_to_tmpl_map(TEMPLATE_PREFIX || '_tt') := TEMPLATE_PREFIX || '_stack';
        g_impl_to_tmpl_map(TEMPLATE_PREFIX || '_type_tt') := TEMPLATE_PREFIX || '_template_type';
        g_impl_to_tmpl_map(TEMPLATE_PREFIX || '_type_tt, /*#base*/') := TEMPLATE_PREFIX || '_template_type_base';
        g_impl_to_tmpl_map(TEMPLATE_PREFIX || '_type_tt /*#base*/') := TEMPLATE_PREFIX || '_template_type_base';
        -- register mapping from script identifier to template implementation object name and type tuples
        register_template_impl_obj(plu_stack.SRC_STACK_VARRAY_TPS, 'TYPE', 'PLU_STACK_VARRAY_TT');
        register_template_impl_obj(plu_stack.SRC_STACK_TPS, 'TYPE', 'PLU_STACK_TT');
        register_template_impl_obj(plu_stack.SRC_STACK_TPB, 'TYPE BODY', 'PLU_STACK_TT');
        --
    end;

begin
    init;
end;
/
