#!/bin/bash

# @FILENAME telegram-makecoffee.sh
# @AUTHOR Gahui, Baek
# @Bot, ServiceKey owner Gahui, Baek
# @Description
# 한국천문연구원_특일 정보: https://www.data.go.kr/tcs/dss/selectApiDataDetailView.do?publicDataPk=15012690

#### build param format ####
# criteria_date: yyyyMMdd
# testMode: true or false
############################

function main() {
  printf "testMode >> ${testMode}\n"
  printf "criteria_date >> ${criteria_date}\n"
#  a=$(isHoliday)
  isHoliday
  a=$? # isHoliday 리턴값 받기 위함
  echo "aa >>>>> $a"
  if [ "$a" == 0 ]; then
    # 공휴일이 아니면 설문 생성
    printf "Let's survey.\n"
    makeCoffee
  else
    printf "It's holiday.\n"
  fi
}

########################################################################
# Confirm holidays data and return whether or not.
########################################################################
function isHoliday() {
  serviceKey=${yourservicekey} # data.go.kr API Service Key
  uri=http://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService
  api=/getRestDeInfo

  today=$(date +'%Y%m%d'); #echo "today is $today"
  solYear=${today:0:4} # value:index:length
  solMonth=${today:4:2}
  if [ ! -z "${criteria_date}" ]; then
    criteria_date=${criteria_date}
    solYear=${criteria_date:0:4} # value:index:length
    solMonth=${criteria_date:4:2}
    today=`date -d "$criteria_date" +%Y%m%d`
  #    today=`date -d "$today +24 day" +%Y%m%d`; echo "new today is $today"
  fi

  options="?_type=json&solYear=$solYear&solMonth=$solMonth&ServiceKey=$serviceKey"
  printf "%s\n" "$options"

  data=$(curl $uri$api$options)

  holidays=($(echo $data | grep -Po '"locdate":[0-9]{8}' | awk -F ":" '{ print $2 }'))

  for i in "${holidays[@]}"
  do
    if [[ $i > $today ]]; then
      isHoliday=0
      break
    fi

    # find holiday
    if [[ $i == $today ]]; then
      # to skip
      isHoliday=1
      break
    fi
  done

  return $isHoliday
}

########################################################################
# Call API what send survey
########################################################################
function makeCoffee() {
  uri=https://api.telegram.org/bot
  token=${yourbottoken}
  api=/sendPoll
  content_type=application/json

  question="<커피 설문> from Shell"
  chat_id="${yourchatid}"

  # 선택지
  options=[\"\(I\)아메리카노\",\"\(\I\)라떼\",\"\(I\)캐모마일\",\"\(H\)아메리카노\",\"\(H\)라떼\",\"\(직접입력\)\"]
#  echo $options

  data="{\"chat_id\":\""$chat_id"\", \"is_anonymous\": false, \"question\": \""$question"\", \"options\": "$options"}"
#  echo "request body >> \n$data"

  curl -w "{} \n결과>> %{http_code}\n" -H "Content-Type: $content_type" -d "$data" $uri$token$api
}

# End function

main "$@" #; exit

# EOF
