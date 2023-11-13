#!/bin/bash -l
export PATH=$PATH:$HOME/energi3/bin
#original Author: @ProjectJourneyman

#updated to use sendgrid
#the following env variables defined must be defined and set:
#   SENDGRID_API_KEY
#   TO_EMAIL_ADDR
#   FROM_EMAIL_ADDR 
#   NRG_ADDR

isRunning=$(energi3 --exec "masternode.masternodeInfo('${NRG_ADDR}')" attach 2>/dev/null | grep -Fq "isActive: true" && echo $?)

isStaking=$(energi3 --exec "miner.stakingStatus()" attach 2>/dev/null | grep -Fq "staking: true" && echo $?)

echo "From Addr" ${FROM_EMAIL_ADDR}
echo "isRunning is: " ${isRunning}
echo "isStaking is: " ${isStaking}

msg="NOT RUNNING"
subj="NRG Staking Status from GCP"

if [[ -n $isRunning && -n $isStaking ]]; then
        msg="running and staking"
elif [[ -n $isRunning ]]; then
        msg="running but not staking - check NRG balance"
elif [[ -n $isStaking ]]; then
        msg="staking but masternode not active"
fi

if [[ $msg == "NOT RUNNING" ]]; then
    https://photos.google.com/album/AF1QipNetnl-jwmlSu99Y8kxVC6hpLH6jsGRBn0TLcdI/photo/AF1QipNljmDzupTuAVY-ohDGy2uKU6h91oC9GBtMKbtWsubj="${subj} - ${msg}"
fi

echo $msg
echo $subj

#send notification via Twilo SendGrid
email_data='{"personalizations": [{"to": [{"email": "'${TO_EMAIL_ADDR}'"}]}],"from": {"email": "'${FROM_EMAIL_ADDR}'"},"subject": "'${subj}'","content": [{"type": "text/plain", "value":"'${msg}'"}]}'

curl --request POST \
    --url https://api.sendgrid.com/v3/mail/send \
    --header "Authorization: Bearer $SENDGRID_API_KEY" \
    --header 'Content-Type: application/json' \
    --data "$email_data"