#!/usr/bin/env python3

# Downloads an arch linux mirrorlist sorted by countries.
# By default, servers are ranked according to downloadspeed within their country
# in the resulting mirrorlist.
# DEPENDENCIES: base-devel, curl, pacman-contrib (for rank_mirrors)
# Uses both IPv4 and IPv6 mirrors.
# HTTPS mirrors only

import os
import re
import datetime

# General settings
rank_mirrors = True     # Controls whether each country's mirrors get ranked by download speed

# Countries in the mirrorlist are ordered according to their position in this dictionary:
# Remove entries here to exclude all servers from the respective country from the mirrorlist.
countries = {
    'DE': 'Germany',
    'NL': 'Netherlands',
    'BE': 'Belgium',
    'FR': 'France',
    'CH': 'Switzerland',
    'AT': 'Austria',
    'CZ': 'Czechia',
    'PL': 'Poland',
    'DK': 'Denmark',
    'IT': 'Italy',
    'SE': 'Sweden',
    'NO': 'Norway',
    'IS': 'Iceland',
    'FI': 'Finland',
    'ES': 'Spain',
    'PT': 'Portugal',
    'IE': 'Ireland',
    'GB': 'United Kingdom',
    'RS': 'Serbia',
    'SK': 'Slovakia',
    'SI': 'Slovenia',
    'HR': 'Croatia',
    'HU': 'Hungary',
    'LT': 'Lithuania',
    'LV': 'Latvia',
    'EE': 'Estonia',
    'BY': 'Belarus',
    'UA': 'Ukraine',
    'MD': 'Moldova',
    'RO': 'Romania',
    'BG': 'Bulgaria',
    'GR': 'Greece',
    'RU': 'Russia',
    'TR': 'Turkey',
    'HK': 'Hong Kong',
    'JP': 'Japan',
    'KR': 'South Korea',
    'US': 'United States'
}

# check if the rankmirrors script is installed
if rank_mirrors:
    if os.system('which rankmirrors 1>/dev/null') != 0:
        # exit if script is not found
        print('Invalid Option: rankmirrors not found in PATH. Aborting...')
        exit(1)

def clean_country_specific_mirrorlist(filename: str, countryname: str) -> None:
    """Cleans up a mirrorlist.
    Removes all lines except lines specifying a server from a mirrorlist in the current directory.
    A header comment naming the country is also added.
    Deletes the file if no servers are listed in it.

    Parameters
    ----------
    filename : str
        the name of the mirrorlist file
    countryname : str
        name of the country to be added as a header comment

    Returns
    -------
    None
    """
    regex_pattern_server = r'^#Server'
    lines_to_keep = []

    # exit if file doesn't exist
    if not os.path.isfile(filename):
        return

    # check if file contains any servers, delete the file and exit if false
    with open(filename, 'r') as infile:
        file_contains_servers = False
        for line in infile:
            match = re.search(regex_pattern_server, line)
            if match is not None:
                file_contains_servers = True
    if not file_contains_servers:
        os.remove(filename)
        return
        
    # add header comment
    lines_to_keep.append('### ' + countryname + '\n')

    # scan the file for Server lines and save them to lines_to_keep[]
    with open(filename, 'r') as infile:
        for line in infile:
            match = re.search(regex_pattern_server, line)
            if match is not None:
                lines_to_keep.append(line)

    # rewrite the file
    os.remove(filename)
    with open(filename, 'w+') as outfile:
        outfile.writelines(lines_to_keep)

# create the full mirrorlist containing all countries
with open('mirrorlist', 'w+') as mirrorlist_total:
    if rank_mirrors:
        print('Generating and ranking mirrorlist...')
    else:
        print('Generating Mirrorlist...')

    # write a header
    if rank_mirrors:
        mirrorlist_total.write('#### pacman mirrorlist (ranked by donwload-speed)\n')
    else:
        mirrorlist_total.write('#### pacman mirrorlist\n')
    mirrorlist_total.write('#### Auto-generated on ' + datetime.datetime.now().strftime(r'%Y-%m-%d %H:%M:%S') + '\n')
    mirrorlist_total.write('\n')
    mirrorlist_total.write('\n')

    for country in countries:
        # console info output
        infostr = 'Getting mirrors for: ' + countries.get(country)
        print(infostr, end=('\r'))

        # create a temporary mirrorlist file for the country
        tempfile_name = country + '.mirrorlist'
        # download the mirrorlist into the tempfile
        url = r"'https://archlinux.org/mirrorlist/?country=" + country + r"&protocol=https&ip_version=4&ip_version=6'"
        os.system('curl ' + url + ' > ' + tempfile_name + ' 2>/dev/null')
        # clean up the temporary mirrorlist
        clean_country_specific_mirrorlist(tempfile_name, countries.get(country))
        # exit loop if file was removed
        if not os.path.isfile(tempfile_name):
            continue

        # rank temp mirrorlist by download speed
        if rank_mirrors:
            # uncomment all servers in temp list
            os.system(r"sed -i 's/^#Server/Server/' " + tempfile_name)
            # move file to a new tempfile
            os.rename(tempfile_name, tempfile_name + '_unranked')
            # sort by speed and remove new tempfile
            os.system(r"rankmirrors " + tempfile_name + '_unranked' + r' > ' + tempfile_name)
            os.remove(tempfile_name + '_unranked')
            # recomment all servers in temp list
            os.system(r"sed -i 's/^Server/#Server/' " + tempfile_name)
            # remove comment line generated by rankmirrors
            os.system(r"sed -i '/^# Server list generated by rankmirrors on .*$/d' " + tempfile_name)

        # append the temp mirrorlist to the total mirrorlist
        lines = []
        with open(tempfile_name, 'r') as tempfile:
            for line in tempfile:
                lines.append(line)
        lines.append('\n')
        mirrorlist_total.writelines(lines)
        os.remove(tempfile_name)

        # clear console info line
        for char in infostr:
            print(' ', end='')
        print(' ', end='\r')

    print('Done!')
