create or replace package plu_stack_impl as

    TEMPLATE_PREFIX     constant plu_stack.object_name_type := 'plu_stack';
    TEMPLATE_TYPE_REGEX constant varchar2(256) := '^([a-z0-9#\$_\.@]+)(\([0-9\*,]+\))?$';

    type string_to_string_map_type is table of plu_stack.object_name_type index by plu_stack.object_name_type;
    g_impl_to_tmpl_map string_to_string_map_type;

    type object_type_name_rec_type is record(
        object_type plu_stack.object_name_type,
        object_name plu_stack.object_name_type);
    type ident_to_template_obj_type is table of object_type_name_rec_type index by plu_stack.script_identifier_type;
    g_ident_to_template_obj ident_to_template_obj_type;

    function valid_template_type(a_template_type in plu_stack.object_name_type) return plu_stack.object_name_type;

    function get_type_base(a_template_type in plu_stack.object_name_type) return plu_stack.object_name_type;

    function get_prefix_from_template_type(a_template_type in plu_stack.object_name_type) return plu_stack.object_name_type;

    function get_template
    (
        a_object_type in plu_stack.object_name_type,
        a_object_name in plu_stack.object_name_type
    ) return clob;

    function get_ddl_scripts
    (
        a_template_type      in plu_stack.object_name_type,
        a_object_name_prefix in plu_stack.object_name_type default null
    ) return plu_stack.ddl_scripts_type;

    function get_tePLSQL_variable_map
    (
        a_object_name_prefix in plu_stack.object_name_type,
        a_template_type      in plu_stack.object_name_type
    ) return teplsql.t_assoc_array;

    function get_ddl_script
    (
        a_template_type      in plu_stack.object_name_type,
        a_script_identifier  in plu_stack.script_identifier_type,
        a_object_name_prefix in plu_stack.object_name_type default null
    ) return clob;

    procedure register_template_impl_obj
    (
        a_script_identifier in plu_stack.script_identifier_type,
        a_object_type       in plu_stack.object_name_type,
        a_object_name       in plu_stack.object_name_type
    );

    procedure init;

end;
/
