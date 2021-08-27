aws cloudformation update-stack \
--stack-name $1 \
--template-body file://$2 \
--parameters file://$3 \
--region=$4 \
--capabilities CAPABILITY_NAMED_IAM
