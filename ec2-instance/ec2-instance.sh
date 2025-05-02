#!/bin/bash

# Load environment variables
ENV_FILE="./ec2-config.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Config file '$ENV_FILE' not found!"
  exit 1
fi

source "$ENV_FILE"

# Confirm loaded values
echo "📦 Launching EC2 with the following configuration:"
echo "  AMI ID:            $AMI_ID"
echo "  Instance Type:     $INSTANCE_TYPE"
echo "  Key Pair:          $KEY_NAME"
echo "  Security Group:    $SECURITY_GROUP_ID"
echo "  Subnet (optional): ${SUBNET_ID:-Not specified}"
echo "  Tag Name:          $TAG_NAME"

# Launch the EC2 instance
LAUNCH_CMD=(
  aws ec2 run-instances
  --image-id "$AMI_ID"
  --count 1
  --instance-type "$INSTANCE_TYPE"
  --key-name "$KEY_NAME"
  --security-group-ids "$SECURITY_GROUP_ID"
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$TAG_NAME}]"
  --query "Instances[0].InstanceId"
  --output text
)

# Add subnet option only if provided
if [ -n "$SUBNET_ID" ]; then
  LAUNCH_CMD+=(--subnet-id "$SUBNET_ID")
fi

echo "🚀 Launching instance..."
INSTANCE_ID=$("${LAUNCH_CMD[@]}")

if [ -z "$INSTANCE_ID" ]; then
  echo "❌ Failed to launch EC2 instance."
  exit 1
fi

echo "✅ Instance launched with ID: $INSTANCE_ID"

# Wait until instance is running
echo "⏳ Waiting for instance to enter 'running' state..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

# Get and display public IP
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "🌐 EC2 Instance is ready!"
echo "  Instance ID: $INSTANCE_ID"
echo "  Public IP:   $PUBLIC_IP"

