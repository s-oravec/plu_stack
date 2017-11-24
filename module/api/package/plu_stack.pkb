create or replace package body plu_stack as

    ----------------------------------------------------------------------------  
    function get_ddl_scripts
    (
        template_type      in object_name_type,
        object_name_prefix in object_name_type default null
    ) return ddl_scripts_type is
    begin
        return plu_stack_impl.get_ddl_scripts(template_type, object_name_prefix);
    end;

    ----------------------------------------------------------------------------
    function get_ddl_script
    (
        template_type      in object_name_type,
        script_identifier  in script_identifier_type,
        object_name_prefix in object_name_type default null
    ) return clob is
    begin
        return plu_stack_impl.get_ddl_script(template_type, script_identifier, object_name_prefix);
    end;

end;
/
