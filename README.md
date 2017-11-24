## Package scripts

Connect as DBA or privileged user (`SYS` is the best) and

### create

Create schema for **plu_stack** as configured in `package.sql`

```
SQL> @create configured <environment>
```

Or create in interactive mode 

```
SQL> @create manual <environment>
```

**Choose from &gt;environment&lt; values**

- `development` - for development of **plu_stack** package - schema receives more privileges
- `production`  - if you just want to use **plu_stack**

### grant

Or you may wish to install plu_stack in already existing schema. Then use the `grant.sql` script to grant privileges required by **plu_stack** package.
Pass **environment** parameter to grant `development` or `production` privileges.

```
SQL> @grant <packageSchema> <environment>
```

### drop

Again either configured or manual. **And it drops cascade. So be carefull. You have been warned**

```
SQL> @drop configured
```
or
```
SQL> @drop manual
```

## Install scripts

You can install either from some privileged deployer user or from within "target" schema.

### set_current_schema

Use this script to change `current_schema`

```
SQL> @set_current_schema <target_schema>
```

### install

Installs module in `current_schema`. (see `set_current_schema`). Can be installed as 

- **public** - grants required privileges on module API to `PUBLIC` (see `/module/api/grant_public.sql`)

```
SQL> @install public
```

- **peer** - sometimes you may want to use package only by schema, where it is deployed - then install it as **peer** package

```
SQL> @install peer
```

### uninstall

Drops all objects created by install.

```
SQL> @uninstall
```

## Use plu_stack from different schemas

When you want to use **plu_stack** from other schemas, you have basically 2 options
- either reference objects granted to `PUBLIC` with qualified name (`<schema>.<object>`)
- or create synonyms and simplify everything (upgrades, move to other schema, use other plu_stack package, ...)

These scripts will help you with latter, by either creating or dropping synonyms for **plu_stack** package API in that schema.

### set_dependency_ref_owner

Creates depenency from reference owner.

```
SQL> conn <some_schema>
SQL> @set_dependency_ref_owner  <schema_where_plu_stack_is_installed>
```

### unset_dependency_ref_owner

Removes depenency from reference owner.

```
SQL> conn <some_schema>
SQL> @unset_dependency_ref_owner  <schema_where_plu_stack_is_installed>
```
