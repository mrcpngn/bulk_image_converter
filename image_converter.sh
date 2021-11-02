#!/bin/bash

# Variable path:
. settings.ini 

# Functions:
# Watermark function
function watermark {

    composite -dissolve ${WATERMARK_OPACITY} \
    -gravity ${WATERMARK_POSITION} \
    ${WATERMARK_PATH} \
    ${IMAGE_IN}/${FILE} \
    ${IMAGE_OUT}/${FILE%.*}_watermarked.${FILE##*.} && \
    rm ${IMAGE_IN}/${FILE}
    
}

# Convert image file format function
function convert_img_format {

    convert \
    ${IMAGE_IN}/${FILE} \
    ${IMAGE_OUT}/${FILE%.*}.${NEW_IMAGE_FORMAT} && \
    rm ${IMAGE_IN}/${FILE}
    

}

# Resize image function
function resize {

    convert \
    ${IMAGE_IN}/${FILE} \
    -adaptive-resize ${RESIZE_VALUE} \
    ${IMAGE_OUT}/${FILE%.*}_resized.${FILE##*.} && \
    rm ${IMAGE_IN}/${FILE}

}

# Resize image and convert file format function
function convert_resize {


    convert \
    ${IMAGE_IN}/${FILE} -adaptive-resize ${RESIZE_VALUE} \
    ${IMAGE_OUT}/${FILE%.*}_converted_resized.${NEW_IMAGE_FORMAT} && \
    rm ${IMAGE_IN}/${FILE}

}


# Main application function
function image_converter {

    # Monitor folder to process.
    inotifywait -m -q --format '%f' -e create -e moved_to -e delete_self $IMAGE_IN | 
    while read FILE; do

        # Watermark Process
        if [ -n "$WATERMARK_PATH" -a -n "$WATERMARK_OPACITY" -a -n "$WATERMARK_POSITION" ]
        then

            watermark
            echo "INFO: ${TIMESTAMP} Done adding watermark ${FILE}" >> $LOG_DIRECTORY

        # Resize image and convert file format Process
        elif [ -n "$NEW_IMAGE_FORMAT" -a -n "${RESIZE_VALUE}" ]
        then

            convert_resize
            echo "INFO: ${TIMESTAMP} Done converting ${FILE} to ${FILE%.*}.${NEW_IMAGE_FORMAT} and resized to ${RESIZE_VALUE}." >> $LOG_DIRECTORY

        # Convert bulk images file format Process
        elif [ -n "$NEW_IMAGE_FORMAT" ]
        then

            convert_img_format
            echo "INFO: ${TIMESTAMP} Done converting ${FILE} to ${FILE%.*}.${NEW_IMAGE_FORMAT}" >> $LOG_DIRECTORY

        # Resize bulk image Process
        elif [ -n "$RESIZE_VALUE" ]
        then
        
            resize
            echo "INFO: ${TIMESTAMP} Done resizing ${FILE} to ${RESIZE_VALUE}" >> $LOG_DIRECTORY

        else

            echo "ALERT: No option is set. Please check the parameters on the settings.ini file" >> $LOG_DIRECTORY
            exit 1

        fi


    done


}


# Application Options:
OPTION=$1

# Starts the Application
if [[ $OPTION = 'start' ]]
then

  echo "INFO: Application Started."
  image_converter </dev/null >/dev/null 2>&1 & disown
  echo $!> $PWD/app.pid
  echo "INFO: ${TIMESTAMP} [PID:$!] Application Started." >> $LOG_DIRECTORY

# Stops the Application
elif [[ $OPTION = 'stop' ]]
then
    
  pkill -P `cat $PWD/app.pid`
  rm $PWD/app.pid
  echo "INFO: Application Stopped."
  echo "INFO: ${TIMESTAMP} Application Stopped." >> $LOG_DIRECTORY


# Restart the Application
elif [[ $OPTION = 'restart' ]]
then
    
  pkill -P `cat $PWD/app.pid`
  rm $PWD/app.pid
  echo "INFO: ${TIMESTAMP} Application Stopped." >> $LOG_DIRECTORY
  echo "INFO: Application Restarted."
  image_converter </dev/null >/dev/null 2>&1 & disown
  echo $!> $PWD/app.pid
  echo "INFO: ${TIMESTAMP} [PID:$!] Application Restarted." >> $LOG_DIRECTORY
  
  

else

  echo "ERROR: Invalid option! Please choose [ start | stop | restart ]."

fi