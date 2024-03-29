#!/bin/bash
# argumentos desde https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

# Get parameters from https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# bash new_script.sh -bsp hellogemrtos_bsp -app hellogemrtos -qpr DE10_NANO_SoC_GHRD -qsys soc_system -dir software -sd e -fat f --board de10nano
# FULL for DE10NANO
# bash new_script.sh -bsp hellogemrtos_bsp -app hellogemrtos -qpr DE10_NANO_SoC_GHRD -qsys soc_system -dir software -sd e -fat f --board de10nano -e -f -debug |& tee new_script.txt
# FULL fro BEMICRO SDK
# bash new_script.sh -bsp hellogemrtos_bsp -app hellogemrtos -qpr grtosproject -qsys qsysgrtos -dir software -sd e -fat f --board bemicrosdk -debug -f -e |& tee new_script.txt

BSP_NAME=""                   #hellogemrtos_bsp
APP_NAME=""                   #hellogemrtos
SOFTWARE_DIR_NAME="software"  #software
QUARTUS_PRJ="0"               # DE10_NANO_SoC_GHRD
QSYS_PRJ="0"                  #soc_system
SD_VOLUME="0"                 #e
FAT_VOLUME="0"                #f
BOARD="0"
APP_INCLUDE_DIR=""
APP_SRC_DIR=""
FULL_COMPILATION=0
EDIT_QSYS=0
DEBUG=0

# To run from command line for testing purposes
# BSP_NAME="hellogemrtos_bsp"                   
# APP_NAME="hellogemrtos"                   
# SOFTWARE_DIR_NAME="software"  
# QUARTUS_PRJ="grtosproject"               
# QSYS_PRJ="qsysgrtos"                 
# SD_VOLUME="0"                 
# FAT_VOLUME="0"                
# BOARD="bemicrosdk"
# APP_INCLUDE_DIR=""
# APP_SRC_DIR=""
# FULL_COMPILATION=1
# EDIT_QSYS=1




# Initialise the error log file in the current directory
error_log_file=$(pwd)/error_log.txt
rm -rf ${error_log_file}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -bsp|--bsp-name) BSP_NAME="$2"; shift ;;
        -app|--app-name) APP_NAME="$2"; shift ;;
        -qpr|--quartus-prj) QUARTUS_PRJ="$2"; shift ;;
        -qsys|--qsys-prj) QSYS_PRJ="$2"; shift ;;
        -dir|--software-dir) SOFTWARE_DIR_NAME="$2"; shift ;;
        -brd|--board) BOARD="$2"; shift ;;
        -sd|--sd-volumne) SD_VOLUME="$2"; shift ;;
        -fat|--fat-volumne) FAT_VOLUME="$2"; shift ;;
        -idir|--inc-dir) APP_INCLUDE_DIR+=" --inc-rdir $2"; shift ;;
        -sdir|--src-dir) APP_SRC_DIR+=" --src-rdir $2"; shift ;;
        -f|--full-compilation) FULL_COMPILATION=1 ;;
        -e|--edit-qsys) EDIT_QSYS=1 ;;
        -debug) DEBUG=1 ;;
        -h|--help) echo "Use ${0##*/} -h | --help | [options]";
                   echo "Options";        
                   echo "[-qsys|--qsys-prj] <qsys_project_name>";
                   echo "    Required. Name of the QSYS project to generate WITHOUT extension.";
                   echo "    The <qsys_project_name>.qsys should be in the current path";
                   echo " ";
                   echo "[-qpr|--quartus-prj] <quartus_project_name>";
                   echo "    Required. Name of the QUARTUS project to compile WITHOUT extension.";
                   echo "    The <quartus_project_name>.qpf should be in the current path";
                   echo " ";
                   echo "[-bsp|--bsp-name] <BSP_project_name>";
                   echo "    Required. Name of the BSP project to be compiled/created.";
                   echo " ";
                   echo "[-app|--app-name] <APPLICATION_project_name>";
                   echo "    Required. Name of the application project to be compiled/created.";
                   echo " ";
                   echo "[-brd|--board] <board_code_name>";
                   echo "    Required. Name of the board. A directory with this name should be in current path";
                   echo "    Valid options: \[de10nano\]";
                   echo " ";                   
                   echo "[-e]";
                   echo "    Optional. Edit Qsys project. The Platform Designer GUI is invoked";
                   echo  "   to edit the QSYS project"
                   echo " ";
                   echo "[-f]";
                   echo "    Optional. Force full project compilation.";
                   echo "    If omitted, only the outdated files are processed"
                   echo " ";
                   echo "[-dir|--software-dir] <directory>";
                   echo "    Optional. Name of the directory in which software application shall"
                   echo "    be created. If omitter, \"software\" will be used";
                   echo "    <BSP_project_name> and <APPLICATION_project_name> directories"
                   echo "    will be created/appended"
                   echo " ";
                   echo "[-sd|--sd-volumne] <drive_letter>";
                   echo "    Optional. Drive letter in which the SD for HPS booting is found";
                   echo "    For example: \"e\" for SD mounted in \"E:\"";
                   echo " ";
                   echo "[-fat|--fat-volumne] <drive_letter>";
                   echo "    Optional. Drive letter in which the SD FAT partition for HPS booting is mounted";
                   echo "    FAT partition may be network mounted through ftps";
                   echo "    For example: \"f\" for SD FAT partition mounted in \"F:\"";
                   echo " ";
                   echo "[-idir|--inc-dir] <include_path>";
                   echo "    Optional. If omitted, only the application path is considered";
                   echo "    If provided, header files (.h) will be searched recursively to be";
                   echo "    included to the application project. There may be as many -idir as required";
                   echo "    Path relative to project directory";
                   echo " ";
                   echo "[-sdir|--src-dir] <source_path>";
                   echo "    Optional. If omitted, only the application path is considered";
                   echo "    If provided, source files (.c) will be searched recursively to be";
                   echo "    included to the application project. There may be as many -sdir as required";
                   echo "    Path relative to project directory";                   
                   echo " ";  
                   echo "[-h|--help]";
                   echo "    Optional. Display help for this tool.";
                   echo " "
                   exit 1;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ "${BSP_NAME}" = "" ]; then
    echo "Error: -bsp | --bsp-name option is required";
    echo "Use ${0##*/} -h | --help for help";
    exit 1
fi

if [ "${BOARD}" = "0" ]; then
    echo "[-brd|--board] option should be defined";
fi

if [ ! -d ./${BOARD} ]; then
    echo "${BOARD} directory not found";
    echo " ";
fi

if [ "${APP_NAME}" = "" ]; then
    echo "Error: -app | --app-name option is required";
    echo "Use ${0##*/} -h | --help for help";
    exit 1
fi

if [ "${DEBUG}" = "1" ]; then
    echo "Print for tracking"
    echo "BSP_NAME : ${BSP_NAME}";
    echo "APP_NAME : ${APP_NAME}";
    echo "SOFTWARE_DIR_NAME : ${SOFTWARE_DIR_NAME}";
    echo "QUARTUS_PRJ : ${QUARTUS_PRJ}";
    echo "QSYS_PRJ : ${QSYS_PRJ}";
    echo "SD_VOLUME : ${SD_VOLUME}";
    echo "FAT_VOLUME : ${FAT_VOLUME}";
    echo "BOARD : ${BOARD}";
    echo "APP_INCLUDE_DIR : ${APP_INCLUDE_DIR}";
    echo "APP_SRC_DIR : ${APP_SRC_DIR}";
    echo "FULL_COMPILATION : ${FULL_COMPILATION}";
    echo "EDIT_QSYS : ${EDIT_QSYS}";

    # Turn echo commands on with variable replacement (set +x turns the echo off)
    set -x
fi

# Copy the boards files if needed
if [ -d ./${BOARD} ]; then
    # Update GeMRTOS IPs
    rm -rf ./${BOARD}/misc/boards 2> ${error_log_file}
    rm -rf ./${BOARD}/AvalonBridge 2> ${error_log_file}
    rm -rf ./${BOARD}/AvalonMonitor 2> ${error_log_file}
    rm -rf ./${BOARD}/GRTOS 2> ${error_log_file}
    rm -rf ./${BOARD}/GRTOS_Multiprocessor 2> ${error_log_file}
    rm -rf ./${BOARD}/qsysscript.tcl 2> ${error_log_file}
    rm -rf ./${BOARD}/grtos_nios_bsp_create.sh 2> ${error_log_file}
    cp -rpu ./misc/gemrtos_ips/AvalonBridge ./${BOARD}/AvalonBridge 2>> ${error_log_file}
    cp -rpu ./misc/gemrtos_ips/AvalonMonitor ./${BOARD}/AvalonMonitor 2>> ${error_log_file}
    cp -rpu ./misc/gemrtos_ips/GRTOS ./${BOARD}/GRTOS 2>> ${error_log_file}
    cp -rpu ./misc/gemrtos_ips/GRTOS_Multiprocessor ./${BOARD}/GRTOS_Multiprocessor 2>> ${error_log_file}
    cp -rpu ./misc/qsysscript.tcl ./${BOARD}/qsysscript.tcl 2>> ${error_log_file}
    chmod 777 -R ./${BOARD}/GRTOS_Multiprocessor 2>> ${error_log_file}
    chmod 777 -R ./${BOARD}/AvalonBridge 2>> ${error_log_file}
    chmod 777 -R ./${BOARD}/AvalonMonitor 2>> ${error_log_file}
    chmod 777 -R ./${BOARD}/GRTOS 2>> ${error_log_file}
    chmod 777 -R ./${BOARD}/qsysscript.tcl 2>> ${error_log_file}      
    # Copy ¨HPS files if board is defined
    if [ -d ./misc/boards/${BOARD} ]; then
        mkdir -p ./${BOARD}/misc/boards 2>> ${error_log_file}
        cp -rpu ./misc/boards/${BOARD} ./${BOARD}/misc/boards/ 2>> ${error_log_file}
        chmod 777 -R ./${BOARD}/misc/boards 2>> ${error_log_file}
    fi
    # Copy the qxp file
    rm -rf ./${BOARD}/GRTOS/grtos.qxp 2>> ${error_log_file}
    cp -rpu ./misc/gemrtos_ips/boards/${BOARD}/grtos.qxp ./${BOARD}/GRTOS/ 2>> ${error_log_file}
    chmod 777 -R ./${BOARD}/GRTOS/ 2>> ${error_log_file}
fi

# Copy HPS creation for corresponding BOARDS
if [ "${BOARD}" = "de10nano" ]; then
    rm -rf ./${BOARD}/create_hps_bsp.sh 2>> ${error_log_file}
    cp -pu ./misc/create_hps_bsp.sh ./${BOARD}/ 2>> ${error_log_file}
    chmod 777 ./${BOARD}/create_hps_bsp.sh
fi

# Change to the project folder
cd ./${BOARD} 2>> ${error_log_file}
pwd 2>> ${error_log_file}

# Remove all the BSP to create from scratch
rm -rf ./${SOFTWARE_DIR_NAME}/${BSP_NAME} 2>> ${error_log_file}
mkdir -p ./${SOFTWARE_DIR_NAME}/${BSP_NAME} 2>> ${error_log_file}
chmod 777 -R ./${SOFTWARE_DIR_NAME}/${BSP_NAME} 2>> ${error_log_file}

# Remove all the application files to create from scratch
rm -rf ./${SOFTWARE_DIR_NAME}/${APP_NAME}/*.map 2>> ${error_log_file}
rm -rf ./${SOFTWARE_DIR_NAME}/${APP_NAME}/*.elf 2>> ${error_log_file}
rm -rf ./${SOFTWARE_DIR_NAME}/${APP_NAME}/*.objdump 2>> ${error_log_file}
rm -rf ./${SOFTWARE_DIR_NAME}/${APP_NAME}/Makefile 2>> ${error_log_file}
rm -rf ./${SOFTWARE_DIR_NAME}/${APP_NAME}/obj 2>> ${error_log_file}
rm -rf ./${SOFTWARE_DIR_NAME}/${APP_NAME}/mem_init 2>> ${error_log_file}


# Get the starting time
START=$(date +%s);

# Open Qsys is argument is equal to al
if [ "${EDIT_QSYS}" = "1" ]; then 
    # Open Qsys to modify the SOPC
    qsys-edit ${QSYS_PRJ}.qsys 2>> ${error_log_file}
fi


generated=`stat -c "%Y" ${QSYS_PRJ}.qsys`
compilated=`stat -c "%Y" ./output_files/${QUARTUS_PRJ}.sof`
if [ $generated -gt $compilated ] || [ ! -f ./output_files/${QUARTUS_PRJ}.sof ] || [ "${FULL_COMPILATION}" = "1" ]; then
    echo "Start a full compilation" 2>> ${error_log_file}
    rm -rf ./db 2>> ${error_log_file}
    rm -rf ./incremental_db 2>> ${error_log_file}

    # Clean the previous Quartus compilation files
    rm -rf ./output_files 2>> ${error_log_file}
    mkdir ./output_files 2>> ${error_log_file}
    chmod 777 -R ./output_files 2>> ${error_log_file}

    # Remove previous qsys generation files
    rm -rf ./${QSYS_PRJ} 2>> ${error_log_file}

    # Remove the previous hps folder to create from scratch
    rm -rf ./hps_isw_handoff 2>> ${error_log_file}

    # Generate the Qsys SOPC
    qsys-generate ${QSYS_PRJ}.qsys --upgrade-ip-cores 2>> ${error_log_file}
    qsys-generate ${QSYS_PRJ}.qsys --synthesis=VERILOG 2>> ${error_log_file}

    # Get  data to produce the BSP settings file for HPS BSP and Nios BSP
    qsys-script --system-file=${QSYS_PRJ}.qsys --script=qsysscript.tcl 2>> ${error_log_file}

    # Create and generate the BSP setting file
    bash grtos_nios_bsp_create.sh ./${SOFTWARE_DIR_NAME}/${BSP_NAME} 2>> ${error_log_file}
    # Execute something like: nios2-bsp hal ./software/hellogrtos_bsp soc_system.sopcinfo --cpu-name GRTOS_Multiprocessor_0_nios2_qsys_1 --cmd "set_setting hal.enable_reduced_device_drivers true" --cmd "set_setting hal.stderr GRTOS_Multiprocessor_0_jtag_uart_1" --cmd "set_setting hal.stdin GRTOS_Multiprocessor_0_jtag_uart_0"  --cmd "set_setting hal.stdout GRTOS_Multiprocessor_0_jtag_uart_0" --cmd "add_section_mapping rstaux GRTOS_Multiprocessor_0_onchip_memory2_0" 

    # Build the BSP
    cd ./${SOFTWARE_DIR_NAME}/${BSP_NAME} 2>> ${error_log_file}
    make clean 2>> ${error_log_file}
    make all 2>> ${error_log_file}
    cd ../../ 2>> ${error_log_file}


    # Generate the Makefile of the application and build
    nios2-app-generate-makefile --bsp-dir ./${SOFTWARE_DIR_NAME}/${BSP_NAME} --app-dir ./${SOFTWARE_DIR_NAME}/${APP_NAME} --elf-name ${APP_NAME}.elf --inc-rdir ./${SOFTWARE_DIR_NAME}/${APP_NAME} --src-rdir ./${SOFTWARE_DIR_NAME}/${APP_NAME} ${APP_INCLUDE_DIR} ${APP_SRC_DIR} 2>> ${error_log_file}

    # Build the application
    cd ./${SOFTWARE_DIR_NAME}/${APP_NAME} 2>> ${error_log_file}
    make clean 2>> ${error_log_file}
    make all 2>> ${error_log_file}
    cd ../../ 2>> ${error_log_file}

    # Make memory initialization files
    cd ./${SOFTWARE_DIR_NAME}/${APP_NAME} 2>> ${error_log_file}
    make mem_init_generate 2>> ${error_log_file}
    cd ../../ 2>> ${error_log_file}
    
    # Compile the Quartus project
    quartus_cmd ${QUARTUS_PRJ}.qpf -c ${QUARTUS_PRJ}.qsf 2>> ${error_log_file}

    # #######################################
    # Compile the Quartus project and create BSP for HPS if required
    bash grtos_hps_bsp_create.sh ${QUARTUS_PRJ} ${SD_VOLUME} ${FAT_VOLUME} ${SOFTWARE_DIR_NAME} ${QSYS_PRJ} ${BOARD} ${error_log_file} 2>> ${error_log_file}
    # #######################################

    END=$(date +%s);
    echo $((END-START)) | awk '{print "Total time elapsed: "int($1/3600)":"int(($1%3600)/60)":"int($1%60)}'
    if [ "${BOARD}" = "de10nano" ]; then
        read -n 1 -s -r -p "Change SD to board and press any key to continue downloading nios ${SOFTWARE_DIR_NAME}"
    fi

else

    # Check if a source file was modified to generate the system
    # from https://stackoverflow.com/questions/4561895/how-to-recursively-find-the-latest-modified-file-in-a-directory
    # agregar find ./misc/gemrtos_ips/ -type f -name "*.qxp" -o -name "*.vhd" para compilacion en quartus
    newest_file=`find ../misc/gemrtos_ips/ -type f -name "*.qxp" -o -name "*.vhd" -o -name "*.qsys" -o -name "*.tcl" -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2 -d " "`
    newest_file_time=`stat -c "%Y" $newest_file`
    generated=`stat -c "%Y" ${QSYS_PRJ}.sopcinfo`
    
    if [ $newest_file_time -gt $generated ]; then
    
        # Generate the Qsys SOPC
        qsys-generate ${QSYS_PRJ}.qsys --upgrade-ip-cores 2>> ${error_log_file}
        qsys-generate ${QSYS_PRJ}.qsys --synthesis=VERILOG 2>> ${error_log_file}
        
    fi
    
    newest_file=`find ../misc/gemrtos_ips/ -type f -name "${QSYS_PRJ}.qsys" -o -name "qsysscript.tcl" -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2 -d " "`
    newest_file_time=`stat -c "%Y" $newest_file`
    generated=`stat -c "%Y" grtos_nios_bsp_create.sh`
    
    if [ $newest_file_time -gt $generated ]; then    
        # Get  data to produce the BSP settings file for HPS BSP and Nios BSP
        qsys-script --system-file=${QSYS_PRJ}.qsys --script=qsysscript.tcl 2>> ${error_log_file}
    fi
    
    # Create and generate the BSP setting file
    bash grtos_nios_bsp_create.sh ./${SOFTWARE_DIR_NAME}/${BSP_NAME} 2>> ${error_log_file}
    # Execute something like: nios2-bsp hal ./software/hellogrtos_bsp soc_system.sopcinfo --cpu-name GRTOS_Multiprocessor_0_nios2_qsys_1 --cmd "set_setting hal.enable_reduced_device_drivers true" --cmd "set_setting hal.stderr GRTOS_Multiprocessor_0_jtag_uart_1" --cmd "set_setting hal.stdin GRTOS_Multiprocessor_0_jtag_uart_0"  --cmd "set_setting hal.stdout GRTOS_Multiprocessor_0_jtag_uart_0" --cmd "add_section_mapping rstaux GRTOS_Multiprocessor_0_onchip_memory2_0" 

    # Build the BSP
    cd ./${SOFTWARE_DIR_NAME}/${BSP_NAME} 2>> ${error_log_file}
    make clean 2>> ${error_log_file} 2>> ${error_log_file} 2>> ${error_log_file}
    make all 2>> ${error_log_file}
    cd ../../ 2>> ${error_log_file}

    # Generate the Makefile of the application and build
    nios2-app-generate-makefile --bsp-dir ./${SOFTWARE_DIR_NAME}/${BSP_NAME} --app-dir ./${SOFTWARE_DIR_NAME}/${APP_NAME} --elf-name ${APP_NAME}.elf --inc-rdir ./${SOFTWARE_DIR_NAME}/${APP_NAME} --src-rdir ./${SOFTWARE_DIR_NAME}/${APP_NAME} 2>> ${error_log_file}

    # Build the application
    cd ./${SOFTWARE_DIR_NAME}/${APP_NAME} 2>> ${error_log_file}
    make clean 2>> ${error_log_file}
    make all 2>> ${error_log_file}
    cd ../../ 2>> ${error_log_file}
    
    END=$(date +%s);
    echo $((END-START)) | awk '{print "Total time elapsed: "int($1/3600)":"int(($1%3600)/60)":"int($1%60)}'    
fi

if [ "${BOARD}" = "bemicrosdk" ]; then
    nios2-configure-sof ./output_files/${QUARTUS_PRJ}.sof
    # PARA DE10-NANO
    # nios2-configure-sof -d 2 output_files/${QUARTUS_PRJ}.sof
fi


jtagconfig -n 2>> ${error_log_file}
# from https://forum.trenz-electronic.de/index.php?topic=1228.0
jtagconfig --setparam 1 JtagClock 9M 2>> ${error_log_file}
jtagconfig.exe --getparam 1 JtagClock 2>> ${error_log_file}

# Open terminal windows for standard outputs
cygstart nios2-terminal -v --flush --no-quit-on-ctrl-d --instance=0 2>> ${error_log_file}
sleep 2s 2>> ${error_log_file}

#cygstart terminal_err.sh
cygstart nios2-terminal -v --flush --no-quit-on-ctrl-d --instance=1 2>> ${error_log_file} 
sleep 2s 2>> ${error_log_file}
#cygstart terminal_1.sh
cygstart nios2-terminal -v --flush --no-quit-on-ctrl-d --instance=2 2>> ${error_log_file}
sleep 2s 2>> ${error_log_file}
#cygstart terminal_2.sh
cygstart nios2-terminal -v --flush --no-quit-on-ctrl-d --instance=3 2>> ${error_log_file}
sleep 2s 2>> ${error_log_file}
#cygstart terminal_3.sh
cygstart nios2-terminal -v --flush --no-quit-on-ctrl-d --instance=4 2>> ${error_log_file}
sleep 2s 2>> ${error_log_file}
cygstart nios2-terminal -v --flush --no-quit-on-ctrl-d --instance=5 2>> ${error_log_file}
sleep 2s 2>> ${error_log_file}

nios2-download --go -r ./${SOFTWARE_DIR_NAME}/${APP_NAME}/${APP_NAME}.elf --instance=0 2>> ${error_log_file}

END=$(date +%s);
echo $((END-START)) | awk '{print "Total time elapsed: "int($1/3600)":"int(($1%3600)/60)":"int($1%60)}'
