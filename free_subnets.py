#!/usr/bin/python

__description__ = 'ipv4 network address analyzer.  prints all unassigned ip blocks'
__author__ = 'Paul Komurka pawlex@gmail.com'
__version__ = '0.1'
__date__ = '2017/09/27'

import ipaddress
import itertools
import operator

_subnets_config="subnets.txt"   ## list of all the defined subnets in CIDR format (127.0.0.1/8)
_networks_config="networks.txt" ## list of all define networks in CIDR format delimited by newline.

def File2Strings(filename):
    try:
        f = open(filename, 'r')
    except:
        return None
    try:
        return map(lambda line:line.rstrip('\n'), f.readlines())
    except:
        return None
    finally:
       f.close()
    #
#

def ipstr2int(ip):
    return int(ipaddress.ip_address(unicode(ip)))

def ipint2str(ip):
    return str(ipaddress.ip_address(ip))

def expandNetwork(network):
    _ = ipaddress.ip_network(unicode(network),False)
    _ = _.__iter__()
    return [int(x) for x in _]
#

def Main():
    _defined_networks = File2Strings(_networks_config);
    _defined_subnets  = File2Strings(_subnets_config);

    _ip_aggregate = []
    _subnet_ip_aggregate = []

    # expand the list of hosts within all defined networks.
    # Make 2 lists: all ips and all ip's within defined subnets.
    for net in _defined_networks:
        _ip_aggregate += expandNetwork(net)

    for subnet in _defined_subnets:
        _subnet_ip_aggregate += expandNetwork(subnet)
    
    # Make a list of the orphaned IP addresses. (not belonging to any assigned
    # subnet)
    global _ip_orphans
    _ip_orphans = []
    for ip_address in _ip_aggregate:
        if ip_address not in _subnet_ip_aggregate:
            #print "%s" % ip_address 
            _ip_orphans.append(ip_address)
        #
    #

    ## Make sequential lists of the leftovers.
    _ = []
    for k, g in itertools.groupby(enumerate(_ip_orphans), lambda (i, x): i-x):
        #print map(operator.itemgetter(1), g)
        _.append([ipint2str(y) for y in map(operator.itemgetter(1), g)])
    _ip_orphans = _

    ##
    ##
    ## Now comes the fun part.  Make the largest aligned subnets out of the left overs.
    _unaligned = []
    _aligned   = []
    print 
    for i in _ip_orphans:
        if(checkSubnetListForAlignment(i)):
            _aligned.append(i)
        else:
            _unaligned.append(i)
        #
    #
    print "Available IP subnets"
    map(printSubnetSummary, _aligned)
    ## Handle the unaligned subnets.  Keep iterating throught the list until we
    ## have made the largest subnets possible.
    for u in _unaligned:
        while(len(u)):
            _largest = getInterval(len(u))
            # check TOP down
            if( checkSubnetListForAlignment(u[0:_largest]) ):
                _sub = u[0:_largest]
                printSubnetSummary( _sub )
                u = [x for x in u if x not in _sub]
            # check bottom up
            elif( checkSubnetListForAlignment(u[(len(u)-_largest):]) ):
                _sub = u[(len(u)-_largest):]
                printSubnetSummary(_sub)
                u = [x for x in u if x not in _sub]
#

def getLastOctet(x):
    return x.split(".")[3]

def checkSubnetListForAlignment(i):
    """ takes an array of hosts """
    """ checks to see if the first host and the number of hosts jive """
    if( int(getLastOctet(i[0])) % len(i) == 0):
        return True
    else:
        return False
#

def checkHostForAlignment(ip,hosts=None,bits=None):
    _numHosts = None
    _subdict = getSubnetLutDict(24)

    if(hosts is None and bits is None):
        return False
    
    if(hosts is None):
        _numHosts = _subdict.keys()[_subdict.values().index(bits)]
    else:
        if(hosts in _subdict.keys()):
            _numHosts = hosts
        else:
            return False
    #
    if( int(getLastOctet(ip)) % _numHosts == 0 ):
        return True
    else:
        return False
    #
#

def hosts2bits(hosts):
    _subdict = getSubnetLutDict(24)
    if( hosts in _subdict ):
        return _subdict[hosts]
    else:
        return 32
#

def bits2hosts(bits):
    _subdict = getSubnetLutDict(24)
    if( bits in _subdict.values() ):
        return _subdict.keys()[_subdict.values().index(bits)]
    else:
        return 32
#

def printSubnetSummary(i):
    print "START:%16s\tEND:%16s\tSIZE:%3d (/%d)"%( i[0],i[-1],len(i), hosts2bits(len(i)))

def getSubnetLutDict(downto):
    """ creates a subnet lut 32:downto entries with corresponding number of hosts as the value"""
    lut = {}
    num_hosts=1; #entrie 0 = 1 host (32 bits)
    entries = range(downto,32+1,1)
    entries.sort()
    entries.reverse()
    for i in entries:
        lut.update({num_hosts:i})
        num_hosts = num_hosts * 2
    return lut
#
def getInterval(n):
    """ gets the closest match (as defined as a key in our dict
    rounded down """
    return min(getSubnetLutDict(24), key=lambda x:abs(x-n))

if __name__ == '__main__':
    Main()
#
