 A location for putting out experimental TCL scripts in source control.

 These scripts can be run by in a think client by running a command like (remember :in can only be used in the think client)
 ```
  script.execute :in file:<root>/scripts/<your script> :arg -name argName argValue
  ```

  If you are planning to utilize your script in an asset.query you should be able to utilize `$id` in your script for the item that was found.

  If you want to install a script to be run in a server you can run commands like the following from the think client.
  ```
  asset.create :namespace /system/scripts :name myScript.tcl :in file:/<root>/scripts/myScript.tcl
  asset.set.executable :id 1006
  ```

And then run it via
```
asset.script.execute :sid path=/system/scripts/myScript.tcl :arg -name logDate
```