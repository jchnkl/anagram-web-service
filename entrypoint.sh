#!/bin/bash

ANAGRAM_SERVICE=/anagram-web-service/anagram-service/dist/build/anagram-service/anagram-service
(${ANAGRAM_SERVICE}) &

COMPLETION_SERVICE=/anagram-web-service/completion-service/dist/build/completion-service/completion-service
(${COMPLETION_SERVICE}) &

WEBUI_SERVICE=/anagram-web-service/webui-service/dist/build/webui-service/webui-service
${WEBUI_SERVICE}
