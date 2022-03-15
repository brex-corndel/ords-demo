# Test REST is wortking

curl -i -k http://localhost:8181/ords/hr/rest-v4/employees/7788

# Setup Roles

BEGIN
  ORDS.create_role(
    p_role_name => 'emp_role'
  );
  
  COMMIT;
END;
/

SELECT id, name
FROM   user_ords_roles
WHERE  name = 'emp_role';

# Setup Privilege

DECLARE
  l_roles_arr    OWA.vc_arr;
  l_patterns_arr OWA.vc_arr;
BEGIN
  l_roles_arr(1)    := 'emp_role';
  l_patterns_arr(1) := '/employees/*';
  
  ORDS.define_privilege (
    p_privilege_name => 'emp_priv',
    p_roles          => l_roles_arr,
    p_patterns       => l_patterns_arr,
    p_label          => 'EMP Data',
    p_description    => 'Allow access to the EMP data.'
  );
   
  COMMIT;
END;
/

SELECT privilege_id, privilege_name, role_id, role_name
FROM   user_ords_privilege_roles
WHERE  role_name = 'emp_role';

SELECT privilege_id, name, pattern
FROM   user_ords_privilege_mappings
WHERE  name = 'emp_priv';

# Now connection will be refused

curl -i -k https://localhost:8443/ords/hr/employees/7788

# Create a new ORDS user

$JAVA_HOME/bin/java -jar ords.war user emp_user emp_role

# Remove OAuth

BEGIN
  ORDS.delete_privilege_mapping(
    p_privilege_name => 'emp_priv',
    p_pattern => '/employees/*'
  );     

  COMMIT;
END;
/

BEGIN
  ORDS.delete_privilege (
    p_name => 'emp_priv'
  );
   
  COMMIT;
END;
/

BEGIN
  ORDS.delete_role(
    p_role_name => 'emp_role'
  );
  
  COMMIT;
END;
/

REF: https://oracle-base.com/articles/misc/oracle-rest-data-services-ords-authentication
