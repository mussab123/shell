#!/usr/local/bin/bash

# START PROVIDED TO STUDENTS
FILENAME='../music-solution.txt'

# File column numbers (starts at 1 instead of 0)
ENTRY_NUMBER_COL=1
ALBUM_TYPE_COL=2
ALBUM_NAME_COL=3
ARTIST_COL=4
FEAT_ARTIST_COL=5
SONG_NAME_COL=6
GENRE_COL=7
RELEASE_YEAR_COL=8
PREV_URL_COL=9

# Main Music Genres
PUNK="punk"
POP="pop"
INDIE="indie"
ROCK="rock"

# This funciton is a black box.  Under no circumstances are you to edit it.
# Furthermore, it is a black box because if something in this function was not taught to you in the textbook
# or in the background section for this assignment, do not use it.  In otherwords, everything you need is in
# the assignment specifications and textbook.
create_directory_structure() {
    IFS=$'\n'   # input field separator (or internal field separator)
    FILE_GENRES=( `cat $FILENAME | cut -d $'\t' -f $GENRE_COL | sort -u ` )
    
    for GENRE in ${FILE_GENRES[@]}; do 
        if [[ $GENRE == "Genre" ]]; then
            continue
        fi

        IFS=' '
        read -ra GENRE_SPLIT <<< $GENRE
        GENRE=`echo "$GENRE" | tr ' ' '-' `
        COUNT=1
        FOUND=1
        NUM_SPLIT="${#GENRE_SPLIT[@]}"

        for SPLIT in ${GENRE_SPLIT[@]}; do
            if [[ $SPLIT == *$INDIE* ]] && [[ ${GENRE_SPLIT[*]} != $INDIE ]]; then
                PARENT_GENRE=$INDIE
            elif [[ $SPLIT == *$PUNK* ]] && [[ ${GENRE_SPLIT[*]} != $PUNK ]]; then
                PARENT_GENRE=$PUNK
            elif [[ $SPLIT == *$POP* ]] && [[ ${GENRE_SPLIT[*]} != $POP ]]; then
                PARENT_GENRE=$POP
            elif [[ $SPLIT == *$ROCK* ]] && [[ ${GENRE_SPLIT[*]} != $ROCK ]]; then
                PARENT_GENRE=$ROCK
            else
                # echo $FOUND
                if [ "$GENRE" = "None" ]; then
                    mkdir -p "uncategorized"
                    break
                elif [[ $FOUND -eq 0 ]]; then   # cases: indie anthem-folk, indie poptimism, indie cafe pop (should  not be)
                    # this if condition will be evaluated as true for:
                    # indie emo, indie folk, indie pop rap, indie poptimism, indie soul, pop edm. pop rap, pop soul
                    if [[ $COUNT -eq $NUM_SPLIT ]]; then                        
                        break
                    fi
                    
                    # this will be hit for indie cafe pop
                    (( COUNT+=1 ))
                    continue
                elif [ $COUNT -ne $NUM_SPLIT ] && [ $FOUND -eq 1 ]; then
                    (( COUNT+=1 ))
                    continue
                else
                    mkdir -p "${GENRE}"
                    continue
                fi
            fi

            mkdir -p "${PARENT_GENRE}/${GENRE}"
            FOUND=0
            (( COUNT+=1 ))
        done
    done
}
# END PROVIDED TO STUDENTS

# TODO
# Create a directory called music if it doesn't already exist
# cd into directory called music
mkdir -p music  # BG: explain mkdir -p
cd music

# START PROVIDED TO STUDENTS
# Following single line is provided
create_directory_structure
# END PROVIDED TO STUDENTS

# TODO
# Everything else.
tail -n+2 $FILENAME | while IFS=$'\t' read LINE     
do
    # echo $LINE
    ENTRY_NUMBER=`echo $LINE | cut -f $ENTRY_NUMBER_COL`
    # BEGIN_OPTIONAL: This would be optional for students to do, I like it because it helps me know it's not stuck somewhere
    if [[ $(( ENTRY_NUMBER % 50 )) == 0 ]]; then
        echo "Processed $ENTRY_NUMBER entries so far..."
    fi
    # END_OPTIONAL

    GENRE=`echo ${LINE,,} | cut -f $GENRE_COL | tr ' ' '-' `        # NOTE TO MARKERS: $(( $GENRE_COL )) syntax also acceptable
    ARTIST=`echo ${LINE,,} | cut -f $ARTIST_COL | tr ' ' '-'`   
    FEAT_ARTIST=`echo ${LINE} | cut -f $FEAT_ARTIST_COL | tr ' ' '_'`
    SONG_NAME=`echo $LINE | cut -f $SONG_NAME_COL`
    if [[ "$FEAT_ARTIST" != "None" ]]; 
    then
        SONG_NAME="$SONG_NAME (ft. $FEAT_ARTIST)" 
    fi
    ALBUM_NAME=`echo $LINE | cut -f $ALBUM_NAME_COL | tr ' ' '_'` 
    ALBUM_TYPE=`echo $LINE | cut -f $ALBUM_TYPE_COL`
    RELEASE_YEAR=`echo $LINE | cut -f $RELEASE_YEAR_COL`
    PREV_URL=`echo $LINE | cut -f $PREV_URL_COL`

    if [[ "$GENRE" = "none" ]]; then
        # these four lines of code are repeated three different times with slight variations
        # makes me believe that this could be a good exam question with getting them to use a function
        mkdir -p "./uncategorized/${ARTIST}"
        FILE_LINE="${SONG_NAME}: ${PREV_URL}"
        FILE_NAME="./uncategorized/${ARTIST}/${RELEASE_YEAR}_-_${ALBUM_NAME}_(${ALBUM_TYPE}).txt"
        grep -sqF -- "$FILE_LINE" "$FILE_NAME" || echo "$FILE_LINE" >> "$FILE_NAME"  #BG: explain syntax to students
        continue
    fi

    IFS=$'\n'
    for DIRECTORY in $(find . -type d -name "*$GENRE*"); do 
        BASE_DIR=`basename $DIRECTORY`
        if [[ $GENRE == $INDIE ]]; then
            DIRECTORY="$INDIE"
        elif [[ $GENRE == $PUNK ]]; then
            DIRECTORY="$PUNK"
        elif [[ $GENRE == $POP ]]; then
            DIRECTORY="$POP"
        elif [[ $GENRE == $ROCK ]]; then
            DIRECTORY="$ROCK"
        elif [[ `basename $DIRECTORY` != $GENRE ]]; then
            continue
        fi
            
        mkdir -p "${DIRECTORY}/${ARTIST}"
        FILE_LINE="${SONG_NAME}: ${PREV_URL}"
        FILE_NAME="${DIRECTORY}/${ARTIST}/${RELEASE_YEAR}_-_${ALBUM_NAME}_(${ALBUM_TYPE}).txt"
        grep -sqF "$FILE_LINE" "$FILE_NAME" || echo "$FILE_LINE" >> "$FILE_NAME"
    done
done

zip ../music.zip -r * > ../zip-output.txt      # BG: provide easy to read man page on what zip -r does