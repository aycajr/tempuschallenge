#!/bin/bash
echo "&@@@@@@@@@@@@@@@@#  @@@@@@@@@@@@(    *@@@%            @@@@,     %@@@@@@@@@@/      %@@.          @@@.      *@@@@@@@@&"
echo ".,,,,,,&@@#,,,,,,.  @@@,,,,,,,,,.    (@@@@*          (@@@@/     %@@.    ,&@@@(    %@@.          @@@.    *@@@(.   ,%#"
echo "       %@@(         @@@              %@@/@@         .@@*@@#     %@@.       @@@    %@@.          @@@.   .@@@"
echo "       %@@(         @@@              &@@ @@@        @@*.@@%     %@@.       (@@,   %@@.          @@@.   ,@@@"
echo "       %@@(         @@@              @@@ (@@#      &@@ .@@&     %@@.       @@@    %@@.          @@@.    #@@@("
echo "       %@@(         @@@@@@@@@@@@    .@@&  @@@,    (@@*  @@@     %@@.     /@@@#    %@@.          @@@.      %@@@@@%"
echo "        %@@(         @@@             ,@@%   @@@   *@@(   @@@     %@@@@@@@@@&,      %@@.          @@@.          /@@@@%"
echo "       %@@(         @@@             /@@#   *@@%  @@&    @@@.    %@@.              %@@.          @@@.             &@@@"
echo "       %@@(         @@@             #@@/    &@@ #@@     &@@,    %@@.              *@@(         *@@@               @@@."
echo "       %@@(         @@@             %@@,     @@&@@.     #@@(    %@@.               &@@(        @@@.              (@@@"
echo "      %@@(         @@@%%%%%%%%%%   @@@.     ,@@@(      (@@#    %@@.                @@@@&*.,#@@@&      /@@&/,,*#@@@&"
echo "      %@@(         @@@@@@@@@@@@@   @@@       #@&       *@@&    %@@.                  /@@@@@@@(         /&@@@@@@@*"
echo ""
echo "                     .,.                        ,,.   .,,"
echo "         %@@@@@@@@.  %@/                        @@/   %@&"
echo "       @@@           %@/                        @@/   %@&"
echo "     ,@@,            %@/ /&@@/      /&@@@#      @@/   %@&     .%@@@(     #%, #@@@#        #@@@( ,%#     .%@@@("
echo "     &@%             %@@@,  %@@*   ,/   .@@&    @@/   %@&   *@@*   &@%   %@@@,  /@@*    %@&.  *@@@%   *@@*   &@%"
echo "     @@(             %@#     #@@         .@@,   @@/   %@&  ,@@      &@/  %@@     .@@   %@(      @@%  ,@@      &@."
echo "     &@&             %@/     /@@   .&@@@&%@@,   @@/   %@&  %@@@@@@@@@@%  %@&      @@   @@       &@%  %@@@@@@@@@@,"
echo "     .@@#            %@/     /@@  /@@     @@,   @@/   %@&  (@&           %@&      @@   &@,      &@%  (@&"
echo "      .@@@,          %@/     /@@  #@@    #@@,   @@/   %@&   &@&          %@&      @@    @@(    &@@%   &@&"
echo "         ,&@@@@@@&.  %@/     /@@   *@@@@%.%@(   @@/   %@&     (@@@@@@%   %@&      @@     .%@@@/ &@#     (@@@@@@%"
echo "                                                                                               .@@,"
echo "                                                                                        (%*..,&@@*"
echo "                                                                                          .,,."
echo ""
echo ""

echo "Please make sure the AWS 'default' profile is configured with an Access Key and Secret Key in order for the code to work.
"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    ./terraform_linux init
    ./terraform_linux plan
    ./terraform_linux apply -auto-approve
elif [[ "$OSTYPE" == "darwin"* ]]; then
    ./terraform_mac init
    ./terraform_mac plan
    ./terraform_mac apply -auto-approve
elif [[ "$OSTYPE" == "cygwin" ]]; then
    ./terraform_linux init
    ./terraform_linux plan
    ./terraform_linux apply -auto-approve
elif [[ "$OSTYPE" == "win32" ]]; then
    ./terraform.exe init
    ./terraform.exe plan
    ./terraform.exe apply -auto-approve
elif [[ "$OSTYPE" == "msys" ]]; then
    ./terraform.exe init
    ./terraform.exe plan
    ./terraform.exe apply -auto-approve
else
    echo "none of the type of OS scripts worked, please run it manually. Call your own terraform from inside the directory"
fi
