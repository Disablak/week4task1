#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule

def run_module():
    module_args = dict(
        path_to_env_file=dict(type='str', required = True),
        environment=dict(type='str', choices=['dev', 'prod'], required = True),
        additional_settings=dict(type='dict'),
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    path_to_env_file = module.params['path_to_env_file']
    environment = module.params['environment']
    additional_settings = module.params['additional_settings']

    value_for_debug = "True" if environment == "dev" else "False";
    additional_settings["DEBUG"] = value_for_debug

    message = []
    for key, value in additional_settings.items():
        message += change_or_add_variable(key, value, path_to_env_file)

    is_changed = len(message) > 0
    message.insert(0, "Changed next lines:" if is_changed else "Nothing changed!")

    module.exit_json(changed=is_changed, msg=message)


def change_or_add_variable(varible_name, varible_value, path_to_env_file):
    replacement_line = varible_name + "=" + str(varible_value) + "\n"
    found = False
    changed_lines = []

    with open(path_to_env_file, "r") as f:
        lines = f.readlines()

    new_lines = []
    for line in lines:
        if varible_name in line:
            new_lines.append(replacement_line)
            found = True

            if not replacement_line in line:
                changed_lines.append(replacement_line)
        else:
            new_lines.append(line)

    if not found:
       new_lines.append(replacement_line)
       changed_lines.append(replacement_line)

    with open(path_to_env_file, "w") as f:
        f.writelines(new_lines)
    
    return changed_lines


def main():
    run_module()

if __name__ == '__main__':
    main()
