# DevOps
# USE CASE-2  Blue Green Deployment
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
 5. We will be using the same application code as used in usecase-1

---------------------------------------

Step 2. Pre-requisites:
     
1. Configure jenkins and Configure "webhook with Githhub" repository(Discussed in earlier slides).
2. Check for all the files in github folder - https://github.com/Rising-Minerva/DevOps/tree/main/Labs/usecases/usecase-2/
3. Please make changes in the file as directed in ``step-4``

---------------------------------------

Step 3. Review code

 1. my_application/application.py - Flask Application main file.
 2. my_application/test.py - Test cases covering all function of the main application. 
 3. Jenkinsfile - Jenkins pipeline file.
 4. requirements.txt - Package dependency required for the application to run.
 5. setup.py - Build setup file for creating python wheel package for distribution. For details description -https://flask.palletsprojects.com/en/2.0.x/patterns/distribute/#installing-developing
 6. terraform/blue/iac_usecase_2.tf - Terraform file for creating application infrastructure for blue cluster.
 6. terraform/green/iac_usecase_2.tf - Terraform file for creating application infrastructure for green cluster.
 

---------------------------------------

Step 4. Changes to Application files

1. Changes in the code files
     1. blue/iac_usecase_2.tf - **BELOW PARAMETERS should be available in your REGION on line 2**
        - [Line#- 7]: - Specify the AWS VPN id.
        - [Line#- 13]: - CIDR IP block from where we want to access the application UI.
        - [Line#- 19]: - Public subnet id.
        - [Line#- 25]: - KEY Name for creating ec2 on which application will be deployed.
        - [Line#- 31]: - AMI Name for creating ec2 on which application will be deployed. Please choose the latest AMI that will have latest aws tools installed
        - [Line#- 37]: - IAM application role which must be attached to the Ec2 on which application is deployed. Created in prerequisite step.
        - [Line#- 42]: - Type of Ec2 Instance.
        - [Line#- 47]: - S3 path to download binary package. **MUST BE EXACTLY SAME AS PATH WHERE jenkinsfile uploads the built binary in STEP 3**
        - [Line#- 53]: - Version to deploy match with the version present in setup.py.
     2. green/iac_usecase_2.tf - **BELOW PARAMETERS should be available in your REGION on line 2**
        - [Line#- 7]: - Specify the AWS VPN id.
        - [Line#- 13]: - CIDR IP block from where we want to access the application UI.
        - [Line#- 19]: - Public subnet id.
        - [Line#- 25]: - KEY Name for creating ec2 on which application will be deployed.
        - [Line#- 31]: - AMI Name for creating ec2 on which application will be deployed. Please choose the latest AMI that will have latest aws tools installed
        - [Line#- 37]: - IAM application role which must be attached to the Ec2 on which application is deployed. Created in prerequisite step.
        - [Line#- 42]: - Type of Ec2 Instance.
        - [Line#- 47]: - S3 path to download binary package. **MUST BE EXACTLY SAME AS PATH WHERE jenkinsfile uploads the built binary in STEP 3**
        - [Line#- 53]: - Version to deploy match with the version present in setup.py.
     3. Jenkinsfile 
        - [line#- 2]: - S3 Bucket **For example: "s3://risingminervacodebase-rchaturvedi"**. **S3 bucket should be present in your region in LINE 2**
        - [line#- 3]: - S3 path to upload the binary package. **For example "devops/app"** DO NOT END in a SLASH. **Should be present in your S3 bucket**
        - [line#- 4]: - S3 path for Terraform create destroy plan. For example "devops/terraform" DO NOT END in a SLASH. **Should be present in your S3 bucket**
     4. Setup.py
        - [Line# -5]: - Version of the application.** IMPORTANT AS YOU WILL DEPLOY TWO DIFFERENT VERSIONS IN BLUE VS GREEN**
---------------------------------------
Step 5. Step By Step Execution
    
 1. Setup and configure jenkins(details present in earlier slides).
 2. Create a githb webhook(details present in earlier slides).
    ![alt text](../../../images/GithubWebHook.png)
    ![alt text](../../../images/GithubWebHook2.png)
    Payload URL is the jenkins URL.
 3. Create the jenkins pipeline.
       - Select new item from jenkins dashboard ![alt text](../../../images/JenkinsNewItem.png)
       - Select pipeline project with any name ![alt text](../../../images/NewJenkinsPipeline.png)
       - Select any log rotation duration according to your use & enter the github URl ![alt text](../../../images/LogRotationAndGithub.png)
       - Select build trigger as Github hook. ![alt text](../../../images/BuildTriggers.png)
       - We will be deploying different tag version on different cluster.
       - In Pipeline section 
            - definition - Pipeline script from SCM (Source code management)
            - SCM - Git
            - Repository URL - github URL
            - Credentials - if Repository is not public
            - Name - origin
            - Refspec (Specify to build tags) 
                - `+refs/tags/*:refs/remotes/origin/tags/*`
            - Branches to build (TAG_VERSION variables will flow from jenkins pipeline parameter)
                - `refs/tags/${VERSION}`
            - Repository browser - Auto
             ![alt text](../../../images/SCM2.png)
            - Make sure **Lightweight checkout is CHECKED OFF**
 4. In the script path - Labs/usecases/usecase-2/Jenkinsfile 
             ![alt text](../../../images/JenkinsFile2.png)
 5. For additional behaviour plugins must be installed like "Github, Wipe repository". Detailed information is present in jenkis configuration slide.
 6. Create the tag and commit the tag to github
    ```
    > git tag 1.0.0
    > git push origin --tags
      Total 0 (delta 0), reused 0 (delta 0)
      To https://github.com/Rising-Minerva/DevOps.git
      * [new tag]         1.0.0 -> 1.0.0
    ```
    We have created the tag 1.0.0 on current master branch.
        ![alt text](../../../images/GitInitialTag.png)
 
 7. Now make some changes in the code and commit the new tag on the latest code
     - We have update the version on Setup.py file. 
     - Also did some major update in code file 'application.py'
     - Commit the code changes and create a new tag on the github.
      ```
    > git tag 1.0.1
    > git push origin --tags
      Total 0 (delta 0), reused 0 (delta 0)
      To https://github.com/Rising-Minerva/DevOps.git
      * [new tag]         1.0.1 -> 1.0.1
    ```
     We have created the tag 1.0.1 on current master branch.
         ![alt text](../../../images/MultipleTags.png)
 
 8. We can also compare code changes in two tags
         ![alt text](../../../images/CompareTags.png)
 
 9. Jenkins pipeline can be triggered from 'Build with parameters''.
         ![alt text](../../../images/NewBuild.png) 
 
 10. We will deploy tag version 1.0.0 on blue server and 1.0.1 on green server.
      - Deploy Blue
           ![alt text](../../../images/Deploy1.png) 
           ![alt text](../../../images/Deploy-1.png) 
            Output
           ![alt text](../../../images/Blue.png) 
      - Deploy Green
            ![alt text](../../../images/Deploy2.png)          
            ![alt text](../../../images/Deploy-2.png)
            Output
           ![alt text](../../../images/Green.png)           
 11. Pipeline logs can be seen by hovering each steps.
            ![alt text](../../../images/NewBuild2.png)
 12. One stage will be skipped [either deployment on green cluster or deployment on blue cluster]             
            ![alt text](../../../images/NewBuild2.png) 
 13. Test result trends is also available for each build.
            ![alt text](../../../images/TestResultTrend.png)              
 14. New version can be made live by pointing LB to the new cluster.
 15. Old version custer can be decommissioned (See Additional Instruction Step.6 point#7)           
 

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
             ![alt text](../../../images/FinalPipeline.png). 
 7. We can destroy old cluster by terraform destroy command when new cluster is created
       - Destroy plan file is uploaded in s3 from jenkins steps 
       - Jenkinsfile - Line# 88, 89, 71, 72 
                
        aws s3 cp ${S3_BUCKET}/${S3_TERRAFORM_PATH}/green/<version>/planfile .
        terraform apply -auto-approve planfile      
        
