# Phase 1 - Step 1: IAM Configuration

## Objective 
Create a group and a userfollowing the best practices from the start, ensuring a secure and minimal-permission environment.

---

## A. Create IAM Group

- **Path:** `IAM → Groups → Create group`
- **Group name:** `devops-student-group`
- **Attached policies:**
    - `AmazonEC2FullAccess`
    - `AmazonVPCFullAccess`
    - `ElasticLoadBalancingFullAccess`
    - `IAMReadOnlyAccess`
    - `CloudWatchReadOnlyAccess`

> Avoid using `AdministratorAccess` to follow the principle of least privilige

---

## B. Create IAM User

- **Path:** `IAM → Users → Add user`
- **Username:** `devops-student`
- **Access type:**
    - Programmatic access 
    - AWS Console access
- **Group membership:** `devops-student-group`

---

## C. Enable MFA 

- Path: `IAM → Users → devops-student → Security credentials → Enable MFA`
- Type: Virtual MFA device (Google auth)
- Status: Succesfully enabled

---

## Notes

We will create an IAM group named TerraformAdmin and an IAM user named TerraformUser with programmatic access via an access key. The access keys will be configured for the user and passed to the AWS CLI for authentication. 