### aws_autoscaling_group.worker: timeout while waiting for state to become
```bash
Error applying plan:

1 error(s) occurred:

* aws_autoscaling_group.worker: timeout while waiting for state to become '[success]'

Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.
```

### Resolution
Run `make destroy` / `make clean` again.
