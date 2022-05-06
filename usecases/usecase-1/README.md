# DevOps
# USE CASE-1 
---------------------------------------
Step 1. Resource creation
    
 1. AWS **account** is required with permission to create role.
 
 2. **VPC** and **Subnet** - In which you want to create infrastructure to deploy the code.
    1. For simplicity and easy access of UI's please select **public subnet**. 
    2. VPC and Subnet must be configured, before running Jenkins pipeline, Create it if not already present.
 3. S3 bucket as binary repository
    1. S3 bucket must be created before running Jenkins pipeline.
 
 4. Create role for EC2 (Application Role)
    1. IAM role for the EC2 on which application is deployed 'EC2_DefaultRole'
       - Attach these service role required for application to run.
            2. AmazonS3FullAccess 
            5. AmazonEc2FullAccess
---------------------------------------

Step 2. Pre-requisites:
     
1. Configure jenkins and Configure "webhook with Githhub" repository(Discussed in earlier slides).
2. Check for all the files in github folder - https://github.com/Rising-Minerva/DevOps/tree/main/Labs/usecases/usecase-1/
3. Please make changes in the file as directed in ``step-4``

---------------------------------------

Step 3. Review code
 1. my_application/application.py - Flask Application main file.
 2. my_application/test.py - Test cases covering all function of the main application. 
 3. Jenkinsfile - Jenkins pipeline file.
 4. requirements.txt - Package dependency required for the application to run.
 5. setup.py - Build setup file for creating python wheel package for distribution. For details description -https://flask.palletsprojects.com/en/2.0.x/patterns/distribute/#installing-developing
 6. terraform/iac_usecase_1.tf - Terraform file for creating application infrastructure.
 7. provider.tf - Terraform cloud provider file to specify the AWS region. 

---------------------------------------

Step 4. Changes to Application files

1. Changes in the code files
     1. provider.tf 
        - [line#- 2]: - AWS region for create resources.
     2. iac_usecase_1.tf 
        - [line#- 3]: - Specify the AWS VPC id.
        - [line#- 8]: - CIDR IP block from where we want to access the application UI.
        - [line#- 20]: - AMI Name for creating ec2 on which application will be deployed. Please choose the latest AMI that will have latest aws tools installed.
                         AMI should be available in the region provided in 'provider.tf'
        - [line#- 26]: - IAM application role which must be attached to the Ec2 on which application is deployed. Created in prerequisite step.
        - [line#- 14]: - Public subnet id.
        - [line#- 37]: - S3 path to download binary package.
     3. Jenkinsfile 
        - [line#- 2]: - S3 Bucket
        - [line#- 3]: - S3 path to upload the binary package. 
          - **SHOULD BE EXACTLY SAME AS LINE 37 OF iac_usecase_1.tf**
        - [line#- 4]: - S3 path for Terraform create destroy plan.
---------------------------------------

Step 5. Step By Step Execution
    
 1. Setup and configure jenkins (details present in earlier slides).
 2. Create a githb webhook(details present in earlier slides).
    ![alt text](../../../images/GithubWebHook.png)
    ![alt text](../../../images/GithubWebHook2.png)
    Payload URL is the jenkins URL.
    
 3. Create the jenins pipeline.
       - Select **New Item** from jenkins dashboard ![alt text](../../../images/JenkinsNewItem.png)
       - Select **pipeline** project with any name ![alt text](../../../images/NewJenkinsPipeline.png)
       - Click **Discard old builds ** 
           - Select any log rotation duration according to your use & enter the github URl ![alt text](../../../images/LogRotationAndGithub.png)
       - Select **Build Trigger as GitHub hook trigger for GITScm polling** ![alt text](../../../images/BuildTriggers.png)
       - In Pipeline section 
            - definition - Pipeline script from SCM (Source code management)
            - SCM - Git
            - Repository URL - github URL
            - Credentials - Provide GITHUB credentials
                - **After August 2021, Github requires access token instead of password**
                - In Github, go to User Profile -> Developer settings and generate a token
                - Use this token in the credentials
            - Click Advanced
                - Name - origin
                - Refspec - `+refs/heads/*:refs/remotes/origin/*`
            - Branches to build - `*/*`
            - Repository browser - Auto
             ![alt text](../../../images/SCM.png)
 4. In the script path - Labs/usecases/usecase-1/Jenkinsfile 
             ![alt text](../../../images/JenkinsFile.png)
 5. For additional behaviour plugins must be installed like "Github, Wipe repository". Detailed information is present in jenkis configuration slide.
 6. Commit the code in the github to trigger the pipeline. You can check the hook delivery matching with commitId.
              ![alt text](../../../images/HookRecentDelivery.png)   
 7. Jenkins pipeline must be triggered.
              ![alt text](../../../images/PipelineStatus.png) 
 8. Pipeline logs can be seen by hovering each steps.
              ![alt text](../../../images/PipelineLogs.png)
 9. Test result trends is also available for each build.
              ![alt text](../../../images/TestResultTrend.png)              
 10. Github Hook Logs can also been seen from dashboard.
             ![alt text](../../../images/HookLog.png)              
 
---------------------------------------

Step 6. Notes/Additional instructions:
    
 1. Check if the binary is successfully updated on s3.
 2. Binary version can be changed from setup.py file - `version='1.0.0'`
 3. Login to AWS to check the resources created 
             ![alt text](../../../images/ec2.png).
 4. Check the security group created
 5. Application can be accessed by ec2 public ip.
             ![alt text](../../../images/Hello.png).    
 6. final pipeline will look like this 
             ![alt text](../../../images/FinalPipeline.png)
 7. Logs on EC2 available in belo log file
     more /var/log/jenkins/jenkins.log
    
