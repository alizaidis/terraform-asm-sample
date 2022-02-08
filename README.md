# Build Anthos Application Development platform with all feature and components on Google Cloud Platform

# Pre-requistes

1. Install Google Cloud SDK
2. Install Terraform
3. Active Anthos trial license

## Steps to deploy the platform:

Components and features : Google Kubernetes Engine, Anthos Config Management, Anthos Config Connector, 

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

    In the output, notice that the `Status` will eventually show as `SYNCED` and the `Last_Synced_Token` will match the repo hash.

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
    fg # ctrl-c

    terraform destroy -var=project=$PROJECT_ID
    ```
