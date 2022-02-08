# Build GKE cluster and deploy Anthos Service Mesh on the cluster.

# Pre-requistes 

1. Install Google Cloud SDK
2. Install Terraform
3. Active Anthos trial license

## Steps to deploy the terraform

1. Clone this repo
1. Set variables that will be used in multiple commands:

    ```bash
    FOLDER_ID = [FOLDER]
    BILLING_ACCOUNT = [BILLING_ACCOUNT]
    PROJECT_ID = [PROJECT_ID]
    ```

1. Create project:

    ```bash
    gcloud auth login
    gcloud projects create $PROJECT_ID --name=$PROJECT_ID --folder=$FOLDER_ID
    gcloud alpha billing projects link $PROJECT_ID --billing-account $BILLING_ACCOUNT
    gcloud config set project $PROJECT_ID
    ```
1. Enable the compute api for the project:

    ```bash
    gcloud services enable compute.googleapis.com --project $PROJECT_ID

    The output is similar to the following:
    Operation "operations/acf.p2-42486643714-242126b9-b72c-49fb-b4b4-53d4dae2101e" finished successfully.
    ```


1. Enable the service mesh feature:

    ```bash
    gcloud container hub mesh enable --project $PROJECT_ID

    The output is similar to the following:

    Enabling service [meshconfig.googleapis.com] on project [xxx]...
    Operation "operations/acat.p2-1063239217441-cd1763ba-264c-4ec2-9346-2e046fc03062" finished successfully.
    API [gkehub.googleapis.com] not enabled on project [1063239217441]. Would you like to enable and retry (this will take a few minutes)? (y/N)?  y

    Enabling service [gkehub.googleapis.com] on project [xxxx]...
    Operation "operations/acat.p2-1063239217441-4a50584e-7ee4-4702-9b61-453ba2a5ba55" finished successfully.
    Waiting for Feature Service Mesh to be created...done. 
    ```

1. Create cluster using terraform using defaults other than the project:

    ```bash
    # obtain user access credentials to use for Terraform commands
    gcloud auth application-default login

    # continue in /terraform directory
    cd terraform
    export TF_VAR_project_id=$PROJECT_ID
    terraform init
    terraform plan
    terraform apply
    ```
   NOTE: if you get an error due to default network not being present, run `gcloud compute networks create default --subnet-mode=auto` and retry the commands.

1. To verify things have sync'ed, you can use `gcloud` to check status:

    ```bash
    gcloud alpha container hub config-management status --project $PROJECT_ID
    ```

1. To review the state the of asm installation, lets inspect the cluster:

    ```bash
    # get values from cluster that was created


    # First lets get the credentials for the GKE cluster 
    gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE --project $PROJECT_ID


    # Inspect the state of controlplanerevision CustomResource
    kubectl describe controlplanerevision asm-managed -n istio-system
    
    The output is similar to the following:


        Name:         asm-managed
        Namespace:    istio-system
        Labels:       mesh.cloud.google.com/managed-cni-enabled=true
        Annotations:  <none>
        API Version:  mesh.cloud.google.com/v1beta1
        Kind:         ControlPlaneRevision
        Metadata:
        Creation Timestamp:  2022-02-04T19:10:56Z
        Generation:          1
        Managed Fields:
            API Version:  mesh.cloud.google.com/v1beta1
            Fields Type:  FieldsV1
            fieldsV1:
            f:metadata:
                f:annotations:
                .:
                f:kubectl.kubernetes.io/last-applied-configuration:
                f:labels:
                .:
                f:mesh.cloud.google.com/managed-cni-enabled:
            f:spec:
                .:
                f:channel:
                f:type:
            Manager:      kubectl-client-side-apply
            Operation:    Update
            Time:         2022-02-04T19:10:56Z
            API Version:  mesh.cloud.google.com/v1alpha1
            Fields Type:  FieldsV1
            fieldsV1:
            f:status:
                .:
                f:conditions:
            Manager:         Google-GKEHub-Controllers-Servicemesh
            Operation:       Update
            Time:            2022-02-04T19:12:50Z
        Resource Version:  14573
        UID:               2b7d5d2c-438d-4a14-9c62-625545ac80d7
        Spec:
        Channel:  regular
        Type:     managed_service
        Status:
        Conditions:
            Last Transition Time:  2022-02-04T19:18:04Z
            Message:               The provisioning process has completed successfully
            Reason:                Provisioned
            Status:                True
            Type:                  Reconciled
            Last Transition Time:  2022-02-04T19:18:04Z
            Message:               Provisioning has finished
            Reason:                ProvisioningFinished
            Status:                True
            Type:                  ProvisioningFinished
            Last Transition Time:  2022-02-04T19:18:04Z
            Message:               Provisioning has not stalled
            Reason:                NotStalled
            Status:                False
            Type:                  Stalled
        Events:                    <none>

    
    # Review the status of the controlplanerevision custom resource named asm-managed, the RECONCILED field should be set to True.
    kubectl get controlplanerevisions -n istio-system

    The output is similar to the following:


            NAME          RECONCILED   STALLED   AGE
            asm-managed   True         False     14m

    # Review the configmaps in the istio-system namespace.

    kubectl get configmaps -n istio-system

    The output is similar to the following:


        NAME                   DATA   AGE
        asm-options            1      20m
        env-asm-managed        3      8m2s
        istio-asm-managed      1      20m
        istio-gateway-leader   0      8m1s
        istio-leader           0      8m1s
        kube-root-ca.crt       1      20m
        mdp-eviction-leader    0      12m



    ```

1. Finally, let's clean up. Apply `terraform destroy` to remove the GCP resources that were deployed to the project.

   ```bash
    Disable the service mesh feature:

    gcloud container hub mesh disable --project $PROJECT_ID

    terraform destroy -var=project_id=$PROJECT_ID
    ```
