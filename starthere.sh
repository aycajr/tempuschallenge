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
    ./terraform init
    ./terraform plan
    ./terraform apply -auto-approve
elif [[ "$OSTYPE" == "darwin"* ]]; then
    ./terraform init
    ./terraform plan
    ./terraform apply -auto-approve
elif [[ "$OSTYPE" == "cygwin" ]]; then
    ./terraform init
    ./terraform plan
    ./terraform apply -auto-approve
elif [[ "$OSTYPE" == "win32" ]]; then
    ./terraform.exe init
    ./terraform.exe plan
    ./terraform.exe apply -auto-approve
elif [[ "$OSTYPE" == "msys" ]]; then
    ./terraform.exe init
    ./terraform.exe plan
    ./terraform.exe apply -auto-approve
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    ./terraform init
    ./terraform plan
    ./terraform apply -auto-approve
else
    echo "none of the type of OS scripts worked, please run it manually. Call your own terraform from inside the directory"
fi
