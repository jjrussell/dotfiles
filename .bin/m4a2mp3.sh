#!/bin/bash

# INPUT_FILES=""
# CONCAT_STREAMS=""
# STREAM_NUMBER=0
# for input_file in "$@"; do
#     INPUT_FILES="${INPUT_FILES} -i \"${input_file}\""
#     CONCAT_STREAMS="${CONCAT_STREAMS}[${STREAM_NUMBER}:0]"
#     STREAM_NUMBER=$((STREAM_NUMBER + 1))
# done

# COMMAND="ffmpeg ${INPUT_FILES} -c:a libmp3lame -q:a 4 -filter_complex '${CONCAT_STREAMS}concat=n=${STREAM_NUMBER}:v=0:a=1[out]' -map '[out]' output.mp3"
# echo "Running command: ${COMMAND}"
# exec ${COMMAND}


# gemini generated
#!/bin/bash

#!/bin/bash

INPUT_FILES=""
CONCAT_FILTER="concat=n=$#:v=0:a=1[out]"
for input_file in "$@"; do
    INPUT_FILES="${INPUT_FILES} -i \"${input_file}\""
done

# Create a temporary file for the filter complex definition
FILTER_FILE=$(mktemp /tmp/concat-filter.XXXXXX)
echo "${CONCAT_FILTER}" > "${FILTER_FILE}"

COMMAND="ffmpeg ${INPUT_FILES} -filter_complex_script \"${FILTER_FILE}\" -map '[out]' -c:a libmp3lame -q:a 4 output.mp3"
echo "Running command: ${COMMAND}"
eval ${COMMAND}

# Remove the temporary filter file
rm "${FILTER_FILE}"
