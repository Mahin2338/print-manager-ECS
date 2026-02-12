
#!/bin/bash
set -e

REGION="eu-west-2"
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
REPO="print-manager"
VERSION=${1:-latest}

echo "Pushing to ECR..."

# Create repo if doesn't exist

# Login

aws ecr get-login-password --region $REGION | \
docker login --username AWS --password-stdin $ACCOUNT.dkr.ecr.$REGION.amazonaws.com

# Build

docker build -t $REPO:$VERSION .

# Tag

docker tag $REPO:$VERSION $ACCOUNT.dkr.ecr.$REGION.amazonaws.com/$REPO:$VERSION


# Push

docker push $ACCOUNT.dkr.ecr.$REGION.amazonaws.com/$REPO:$VERSION


echo " Done! Image URI:"
echo "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/$REPO:$VERSION"
