#!/bin/bash



dictionary=()  # Declare an indexed array

# We used the associative arrays at first but turns out it saves values not in the order

# in which values in the file are saved







dictionary_file="dictionary.txt"



while true; do

    echo "Program Menu:"

    echo " "

    echo "1. Check if dictionary.txt exists"

    echo " "

    echo "2. Exit"

    echo " "



    read -p "Enter your choice: " choice



    case $choice in

        1)

            echo "Does the dictionary.txt file exist? (yes/no)"

            read answer



            if [[ $answer =~ ^[Yy][Ee][Ss]$ ]]; then

                read -p "Enter the path of the directory you want to navigate to: " user_input



                # Check if the provided path exists and is a directory

                if [ -d "$user_input" ]; then

                    cd "$user_input"  # Change directory to the user-provided path

                    echo "You have navigated to: $(pwd)"

                    echo " "

                    if [ -e "$dictionary_file" ]; then

                        echo "dictionary.txt is found successfully"

                        echo " "

                    fi

                else

                    echo "Invalid path or not a directory."

                    echo " "

                fi



            elif [[ $answer =~ ^[Nn][Oo]$ ]]; then

                echo "dictionary.txt does not exist."

                touch dictionary.txt

            else

                echo "Invalid answer."

            fi



            break

            ;;



        2)

            echo "Exiting from the program ..."

            exit 0

            break

            ;;



        *)

            echo "Invalid choice. Please select a valid option."

            ;;

    esac

done



while true; do

    echo " ------------------------------------------------"

    echo "Now choose one of these operations to perform:"

    echo " "

    echo "Enter c, compress, or compression to compress a file"

    echo " "

    echo "Enter d, decompress, or decompression to decompress a file"

    echo " "

    echo "Enter q to Quit the program"

    echo " ------------------------------------------------"



    read -p "Enter your choice: " choice



    # Convert the user's choice to lowercase for case-insensitive comparison

    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')



    case $choice in

        c|compress|compression)

            echo "Performing compression..."

            



            read -p "Enter the path of the file to compress: " compressDir



            # Check if the provided path exists and is a directory

            if [ -d "$compressDir" ]; then

                cd "$compressDir"  # Change directory to the user-provided path

                echo "You have navigated to: $(pwd)"

                echo " "

                read -p "Enter the name of file as name.txt " file_name



                if [ -e "$file_name" ]; then

                    echo "$file_name is found successfully"

                    echo " "

                    #echo dictionary_file > ""

                    # Ask the user for a file name and read its content into the 'paragraph' variable



                    if [ -f "$file_name" ]; then

                        paragraph=$(<"$file_name")

                    else

                        echo "File not found or doesn't exist."

                        exit 1

                    fi

                    

                    

                    if [ "$(wc -m < "$file_name")" -gt 0 ]; then

                        charNum=$(wc -m < "$file_name")

                        uncompsize=$((charNum * 16))

                        echo "uncompressed file size = $uncompsize"

                    else

                        echo "file is empty"

                        exit 1

                    fi





                    # Initialize arrays

                    content=()



                    # Initialize variables

                    current_word=""



                    # Iterate through each character in the paragraph

                    for ((i=0; i<${#paragraph}; i++)); do

                        char="${paragraph:i:1}"



                        # Check if the character is a space, punctuation, or newline

                        if [[ "$char" =~ [[:space:][:punct:]] ]]; then

                            # Check if the current word is not empty, then add it to the content array

                            if [ -n "$current_word" ]; then

                                content+=("$current_word")

                                current_word=""

                            fi

                            current_separator="$char"

                            # Replace space separator with the word "space"

                            if [ "$current_separator" = " " ]; then

                                current_separator="space"

                            fi

                            if [ "$current_separator" = $'\n' ]; then

                                current_separator="\\n"

                            fi

                            content+=("$current_separator")

                        else

                            current_word="${current_word}${char}"

                        fi

                    done





                    # Add the last word if it exists

                    if [ -n "$current_word" ]; then

                        content+=("$current_word")

                    fi



                    # Remove the existing compression.txt file if it exists

                        echo "Checking for the existence of compression.txt..."

                        if [ -e "compression.txt" ]; then

                            echo "compression.txt found. Removing..."

                            rm "compression.txt"

                            echo "compression.txt removed."

                        else

                            echo "compression.txt not found."

                        fi



                    # Check if the dictionary file exists and is empty

                    if [ ! -s "dictionary.txt" ]; then

                        # Create the dictionary file and assign codes to items in content

                        current_code=0

                        added_newline=false  # Flag to track if \n has been added



                        for item in "${content[@]}"; do

                            # Check if the item is '\n' and has not been added already

                            if [ "$item" = "\\n" ] && ! "$added_newline"; then

                                echo "0x$(printf '%04X' $current_code) $item" >> dictionary.txt

                                ((current_code++))

                                added_newline=true  # Mark \n as added

                            elif [ "$item" != "\\n" ] && ! grep -qE "^0x[0-9A-Fa-f]+ $item$" dictionary.txt; then

                                echo "0x$(printf '%04X' $current_code) $item" >> dictionary.txt

                                ((current_code++))

                            fi

                        done



                        declare -A word_dictionary



                        # Create the word dictionary

                        create_dictionary() {

                            while read -r line; do

                                code=$(echo "$line" | cut -d ' ' -f1)

                                word=$(echo "$line" | cut -d ' ' -f2-)

                                word_dictionary["$word"]=$code

                            done < dictionary.txt

                        }



                        #create_dictionary



                        





                        # Iterate through content array and print word, dictionary word, and code

                        for item in "${content[@]}"; do

                            if [ -n "${word_dictionary[$item]}" ]; then

                                code="${word_dictionary[$item]}"

                                echo "$code"

                                echo "$code" >> compression.txt

                                # echo "Content Word: $item | Dictionary Word: $item | Code: $code"

                            else

                                echo "Word not found in dictionary: $item"

                            fi

                        done

                    fi



                    



                    # Check if the dictionary file exists and is not empty

                    if [ -s "dictionary.txt" ]; then

                        declare -A word_dictionary



                        # Create the word dictionary

                        create_dictionary() {

                            while read -r line; do

                                code=$(echo "$line" | cut -d ' ' -f1)

                                word=$(echo "$line" | cut -d ' ' -f2-)

                                word_dictionary["$word"]=$code

                            done < dictionary.txt

                        }



                        create_dictionary



                        # Find the code of the last word in the dictionary

                        last_line=$(tail -n 1 dictionary.txt)

                        last_code_hex=${last_line%% *}

                        last_code_int=$((16#${last_code_hex#0x}))



                        # Iterate through content array and add new words to the dictionary

                        for item in "${content[@]}"; do

                            if [ -z "${word_dictionary[$item]}" ]; then

                                # Word is not in the dictionary, add it with a new code

                                new_code_int=$((last_code_int + 1))

                                new_code_hex=$(printf '%04X' "$new_code_int")

                                echo -e "0x${new_code_hex} $item" >> dictionary.txt

                                word_dictionary["$item"]="0x${new_code_hex}"

                                ((last_code_int++))

                            fi

                        done



                        # ... (same compression code as before)

                        # Iterate through content array and print word, dictionary word, and code

                        for item in "${content[@]}"; do

                            if [ -n "${word_dictionary[$item]}" ]; then

                                code="${word_dictionary[$item]}"

                                echo "$code"

                                echo "$code" >> compression.txt

                                # echo "Content Word: $item | Dictionary Word: $item | Code: $code"

                            else

                                echo "Word not found in dictionary: $item"

                            fi

                        done

                    fi



                    if [ "$(wc -l < compression.txt)" -gt 0 ]; then

                        lineNum2=$(wc -l < compression.txt)

                        compsize=$((lineNum2 * 16))

                        echo "compressed file size = $compsize"



                        

                        ratio=$(echo "scale=2; $uncompsize / $compsize" | bc)



                        echo "File compression ratio is : $ratio"

                    else

                        echo "file is empty"

                        exit 1

                    fi



                else

                    echo "file cannot be found"

                fi

            else

                echo "directory can't be found"

            fi

            ;;

        d|decompress|decompression)

            echo "Performing decompression..."



            read -p "Enter the path of the file to decompress: " dcompressDir



            # Check if the provided path exists and is a directory

            if [ -d "$dcompressDir" ]; then

                cd "$dcompressDir"  # Change directory to the user-provided path

                echo "You have navigated to: $(pwd)"

                read -p "Enter the name of file as name.txt " file_name



                if [ -e "$file_name" ]; then

                    echo "$file_name is found successfully"



                    compressed_codes=($(<"$file_name"))



                   



                    declare -A word_dictionary



                        # Create the word dictionary

                    create_dictionary() {

                        while read -r line; do

                            code="${line%% *}"

                            word="${line#* }"

                            word_dictionary["$word"]=$code

                            done < dictionary.txt

                        }



                    create_dictionary









                    # Iterate through compressed codes and retrieve corresponding words

                    for code in "${compressed_codes[@]}"; do

                        found_word=""

                        for word in "${!word_dictionary[@]}"; do

                            if [ "${word_dictionary[$word]}" = "$code" ]; then

                                found_word="$word"

                                break

                            fi

                        done



                        if [ -n "$found_word" ]; then

                            echo "Word for code '$code': $found_word"

                        else

                            echo "Code '$code' not found in the word dictionary."

                        fi

                    done

                else

                    echo "File not found or doesn't exist."

                    exit 1

                fi



                # Write decompression into a file



                # Check if the decompression.txt file exists or create it

                decompression_file="decompression.txt"



                if [ -e "$decompression_file" ]; then

                    rm "$decompression_file"

                fi



                touch "$decompression_file"



                # Iterate through compressed codes and retrieve corresponding words

                for code in "${compressed_codes[@]}"; do

                    found_word=""

                    for word in "${!word_dictionary[@]}"; do

                        if [ "${word_dictionary[$word]}" = "$code" ]; then

                            found_word="$word"

                            break

                        fi

                    done



                    if [ -n "$found_word" ]; then

                        if [ "$found_word" = "space" ]; then

                            echo -n ' ' >> "$decompression_file"

                        elif [ "$found_word" = '\n' ]; then

                            echo >> "$decompression_file"

                        else

                            echo -n "$found_word" >> "$decompression_file"

                        fi

                    else

                        echo "'$code' NOT FOUND!!" >> "$decompression_file"

                    fi

                done



                echo "Decompression completed. Output written to $decompression_file"

            else

                echo "File not found or doesn't exist."

                exit 1

            fi

            ;;



        q|quit)

            echo "Exiting..."

            exit 0

            ;;



        *)

            echo "Invalid option. Please choose 'c' for compression, 'd' for decompression, or 'q' to quit."

            ;;

    esac

done