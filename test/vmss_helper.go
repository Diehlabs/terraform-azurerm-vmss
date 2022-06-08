package test

import (
	"context"
	"log"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/compute/armcompute"
)

// GetVMSS gets the specified VMSS info
func GetVMSS(ctx context.Context, SubscriptionId string, resourceGrouName string, vmssName string) (armcompute.VirtualMachineScaleSet, error) {

	cred, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		log.Fatal(err)
	}

	vmssClient := armcompute.NewVirtualMachineScaleSetsClient(SubscriptionId, cred, nil)

	res, err := vmssClient.Get(
		ctx,
		resourceGrouName,
		vmssName,
		&armcompute.VirtualMachineScaleSetsClientGetOptions{Expand: nil})

	// log.Printf("Response result: %#v\n", res.VirtualMachineScaleSetsClientGetResult)
	return res.VirtualMachineScaleSet, err

}
