namespace: demo
flow:
  name: CreateVM
  inputs:
    - host: 10.0.46.10
    - username: "Capa1\\1269-capa1user"
    - password: Automation123
    - datacenter: Capa1 Datacenter
    - image: Ubuntu
    - folder: Students/Mark
    - prefix_list: '1-,2-,3-'
  workflow:
    - uuid:
        do:
          io.cloudslang.demo.uuid: []
        publish:
          - uuiud: '${"derek-" + uuiud}'
        navigate:
          - SUCCESS: substring
    - substring:
        do:
          io.cloudslang.base.strings.substring:
            - origin_string: '${uuiud}'
            - end_index: '14'
        publish:
          - id: '${new_string}'
        navigate:
          - SUCCESS: clone_vm
          - FAILURE: on_failure
    - clone_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.vm.clone_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_source_identifier: name
              - vm_source: '${image}'
              - datacenter: '${datacenter}'
              - vm_name: '${prefix+id}'
              - vm_folder: '${folder}'
              - mark_as_template: 'false'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: power_on_vm
          - FAILURE: on_failure
    - power_on_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.power_on_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: wait_for_vm_info
          - FAILURE: on_failure
    - wait_for_vm_info:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.util.wait_for_vm_info:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - datacenter: '${datacenter}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        publish:
          - ip_list: '${str([str(x["ip"]) for x in branches_context])}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - ip_list: '${ip_list}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      uuid:
        x: 137
        y: 117
      substring:
        x: 276
        y: 98
      clone_vm:
        x: 340
        y: 331
      power_on_vm:
        x: 478
        y: 259
      wait_for_vm_info:
        x: 595
        y: 245
        navigate:
          0af321ca-75ac-bdf6-158a-f5b2f04d5d81:
            targetId: 3c799fef-28ce-5bfb-15d2-31bf41fb0eb1
            port: SUCCESS
    results:
      SUCCESS:
        3c799fef-28ce-5bfb-15d2-31bf41fb0eb1:
          x: 653
          y: 88
