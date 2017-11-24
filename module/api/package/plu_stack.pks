create or replace package plu_stack as

    subtype object_name_type is varchar2(128);
    type ddl_scripts_type is varray(2147483647) of clob;

    subtype script_identifier_type is pls_integer range 1 .. 3 not null;
    -- ordered in "create order"
    SRC_STACK_VARRAY_TPS constant script_identifier_type := 1;
    SRC_STACK_TPS        constant script_identifier_type := 2;
    SRC_STACK_TPB        constant script_identifier_type := 3;

    function get_ddl_scripts
    (
        template_type      in object_name_type,
        object_name_prefix in object_name_type default null
    ) return ddl_scripts_type;

    function get_ddl_script
    (
        template_type      in object_name_type,
        script_identifier  in script_identifier_type,
        object_name_prefix in object_name_type default null
    ) return clob;

end;
/
