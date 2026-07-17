" Vim syntax file
" Language: BIRD2 Configuration
" Scope:    BIRD2 config files (bird2, .conf)
" Version:  1.0.13-20260717
" License:  MPL-2.0
" Author:   BIRD Chinese Community (Alice39s) <dev-bird@xmsl.dev>
" Based on: grammars/bird2.tmLanguage.json (1.0.13-20260717)

" ------------------------
" Initialization
" ------------------------
if exists("b:current_syntax")
  finish
endif

" ------------------------
" Syntax case
" ------------------------
syntax case match

" Generic identifiers are defined before specialized matches so protocol
" phrases, attributes, constants, and operators retain priority.
syn match  bird2Variable    "[a-zA-Z_][a-zA-Z0-9_]*\>"

" ------------------------
" Comments (repository.comments)
" ------------------------
syn match  bird2Comment   "#.*$" contains=@Spell
syn region bird2Comment   start=/\/\*/ end=/\*\// contains=@Spell

" ------------------------
" Strings (repository.strings)
" ------------------------
syn region bird2String    start=+"+ skip=+\\"+ end=+"+ contains=bird2Escape
syn match  bird2QuotedSymbol "'[0-9A-Za-z_.:-]\+'"
syn match  bird2Escape    "\\." contained

" ------------------------
" Numbers & Time Units (repository.numbers)
" ------------------------
syn match  bird2HexNumber   "\<0x[0-9a-fA-F]\+\>"
syn match  bird2TimeUnit    "\<[0-9]\+\s*\(s\|ms\|us\)\>" contains=bird2Number
syn match  bird2Number      "\<[0-9]\+\>"

" ------------------------
" IP Addresses (repository.ip-addresses)
" ------------------------
" IPv4 with optional prefix (simplified for Vim NFA)
syn match  bird2IPv4       "\<[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\>\%(\/[0-9]\{1,2}\)\?"
" IPv6 patterns (simplified for Vim NFA)
syn match  bird2IPv6       "\<[0-9a-fA-F:]\+::[0-9a-fA-F:]*\>\%(\/[0-9]\{1,3}\)\?"
syn match  bird2IPv6       "::[0-9a-fA-F:]\+\>\%(\/[0-9]\{1,3}\)\?"
syn match  bird2IPv6       "\<[0-9a-fA-F]\{1,4}\%(:[0-9a-fA-F]\{0,4}\)\{1,7}\>\%(\/[0-9]\{1,3}\)\?"

" ------------------------
" VPN Route Distinguisher (repository.vpn-rd)
" ------------------------
syn match  bird2VpnRD      "\<[0-9]\+:[0-9]\+\>"
syn match  bird2VpnRD      "\<[0-9]\+:[0-9]\+:[0-9]\+\>"
syn match  bird2VpnRD      "\<[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}:[0-9]\+\>"

" ------------------------
" Byte Strings (repository.bytestrings)
" ------------------------
syn match  bird2ByteString "\<hex:[0-9a-fA-F]\{2}\%([:\-\.[:space:]]*[0-9a-fA-F]\{2}\)*\>"
syn match  bird2ByteString "\<[0-9a-fA-F]\{2}\%([:\-\.[:space:]]*[0-9a-fA-F]\{2}\)\{15,}\>"
syn match  bird2ByteString "\<[0-9a-fA-F]\{32,}\>"

" ------------------------
" BGP Paths (repository.bgp-paths)
" ------------------------
syn region bird2BgpPath    start="\[=" end="=\]" contains=bird2BgpWildcard,bird2ASN,bird2Number
syn match  bird2BgpWildcard "[*?+]" contained
syn match  bird2ASN        "\<[0-9]\+\>" contained

" ------------------------
" Prefixes (repository.prefixes)
" ------------------------
syn match  bird2Prefix     "\<[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\/[0-9]\{1,2}\>\%([\+\-]\)\?"
syn match  bird2Prefix     "\%([0-9A-Za-z_:]\)\@<!\%([0-9a-fA-F]\{0,4}:\)\{1,7}[0-9a-fA-F]\{0,4}\/[0-9]\{1,3}\>\%([\+\-]\)\?"
syn match  bird2Prefix     "\<[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\/[0-9]\{1,2}\>{[0-9]\+,[0-9]\+}"

" ------------------------
" Filter Definitions (repository.filter-definitions)
" ------------------------
syn region bird2FilterDef  matchgroup=bird2Keyword start="\<filter\>\s\+\ze\%([a-zA-Z_][a-zA-Z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)\s*{" matchgroup=bird2Delimiter end="}" contains=bird2FilterName,@bird2All fold keepend
syn match  bird2FilterName "\%([a-zA-Z_][a-zA-Z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)" contained nextgroup=bird2FilterBody skipwhite skipnl
syn region bird2FilterBody matchgroup=bird2Delimiter start="{" end="}" contained contains=@bird2All fold

" ------------------------
" Function Definitions (repository.function-definitions)
" ------------------------
syn region bird2FunctionDef matchgroup=bird2Keyword start="\<function\>\s\+\ze\%([a-zA-Z_][a-zA-Z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)\s*(" matchgroup=bird2Delimiter end="}" contains=bird2FunctionName,bird2FunctionParams,@bird2All fold keepend
syn match  bird2FunctionName "\%([a-zA-Z_][a-zA-Z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)" contained nextgroup=bird2FunctionParams skipwhite
syn region bird2FunctionParams matchgroup=bird2Delimiter start="(" end=")" contained contains=bird2Type,bird2Variable nextgroup=bird2ReturnType,bird2FunctionBody skipwhite skipnl
syn match  bird2ReturnType "->" contained nextgroup=bird2Type skipwhite
syn region bird2FunctionBody matchgroup=bird2Delimiter start="{" end="}" contained contains=@bird2All fold

" ------------------------
" Template Definitions (repository.template-definitions)
" ------------------------
syn match  bird2TemplateDef "\<template\>\s\+[a-zA-Z_][a-zA-Z0-9_]*\%(\s\+\%([a-zA-Z_][a-zA-Z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)\%(\s\+from\s\+\%([a-zA-Z_][a-zA-Z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)\)\?\)\?\s*{" contains=bird2Keyword,bird2ProtocolTypeKw,bird2TemplateName nextgroup=bird2TemplateBody
syn match  bird2ProtocolType "[a-zA-Z_][a-zA-Z0-9_]*" contained nextgroup=bird2TemplateName skipwhite
syn match  bird2TemplateName "\%([a-zA-Z_][a-zA-Z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)" contained nextgroup=bird2TemplateBody skipwhite skipnl
syn region bird2TemplateBody matchgroup=bird2Delimiter start="{" end="}" contained contains=@bird2All fold

" ------------------------
" Protocol Definitions (repository.protocol-definitions)
" ------------------------
" Protocol with template
syn match  bird2ProtocolDefWithTemplate "\<protocol\>\s\+[a-zA-Z_][a-zA-Z0-9_]*\s\+\%([a-zA-Z_][a-zA-Z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)\s\+from\s\+\%([a-zA-Z_][a-zA-Z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)\s*{" contains=bird2Keyword,bird2ProtocolTypeKw,bird2ProtocolName,bird2TemplateName nextgroup=bird2ProtocolBody
" Protocol with name
syn match  bird2ProtocolDefWithName "\<protocol\>\s\+[a-zA-Z_][a-zA-Z0-9_]*\s\+\%([a-zA-Z_][a-zA-Z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)\s*{" contains=bird2Keyword,bird2ProtocolTypeKw,bird2ProtocolName nextgroup=bird2ProtocolBody
" Anonymous protocol
syn match  bird2ProtocolDefAnonymous "\<protocol\>\s\+[a-zA-Z_][a-zA-Z0-9_]*\s*{" contains=bird2Keyword,bird2ProtocolTypeKw nextgroup=bird2ProtocolBody
syn match  bird2ProtocolName "\%([a-zA-Z_][a-zA-Z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)" contained nextgroup=bird2ProtocolBody skipwhite skipnl
syn region bird2ProtocolBody matchgroup=bird2Delimiter start="{" end="}" contained contains=@bird2All fold

" ------------------------
" Next Hop Statements (repository.next-hop-statements)
" ------------------------
syn match  bird2NextHopIPv4 "\<next hop\>\s\+ipv4\s\+[0-9\.]\+" contains=bird2RoutingKw,bird2IPv4
syn match  bird2NextHopIPv6 "\<next hop\>\s\+ipv6\s\+[0-9a-fA-F:]\+" contains=bird2RoutingKw,bird2IPv6
syn match  bird2NextHopSelf "\<next hop\>\s\+self\>" contains=bird2RoutingKw,bird2SemanticModifier
syn match  bird2ExtendedNextHop "\<extended next hop\>\s\+\%(on\|off\)\>" contains=bird2RoutingKw,bird2SemanticModifier
syn match  bird2NextHopPrefer "\<next hop\>\s\+prefer\s\+\%(global\|local\|native\|ipv6\)\>" contains=bird2RoutingKw,bird2SemanticModifier
syn match  bird2NextHopKeep   "\<next hop\>\s\+keep\%(\s\+\%(ibgp\|ebgp\)\)\?\>" contains=bird2RoutingKw,bird2SemanticModifier
syn match  bird2NextHopAddr   "\<next hop\>\s\+address\s\+[0-9a-fA-F:.]\+" contains=bird2RoutingKw,bird2IPv4,bird2IPv6
syn match  bird2RequireExtNexthop "\<require extended next hop\>\s\+\%(yes\|no\|on\|off\|true\|false\)\>" contains=bird2RoutingKw,bird2SemanticModifier

" ------------------------
" Neighbor Statements (repository.neighbor-statements)
" ------------------------
syn match  bird2LocalAsStmt "\<local\>\s\+\%([0-9a-fA-F:.]\+\|[A-Za-z_][A-Za-z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)\%(\s\+port\s\+\%([0-9]\+\|[A-Za-z_][A-Za-z0-9_]*\)\)\?\s\+as\s\+\%([0-9]\+\|[A-Za-z_][A-Za-z0-9_]*\)\>" contains=bird2Structure,bird2IPv4,bird2IPv6,bird2QuotedSymbol,bird2Variable,bird2Number
syn match  bird2LocalAsTemplate "\<local\>\s\+as\s\+\%([0-9]\+\|[A-Za-z_][A-Za-z0-9_]*\)\>" contains=bird2Structure,bird2SemanticModifier,bird2Variable,bird2Number
syn match  bird2NeighborStmt "\<neighbor\>\s\+\%([0-9a-fA-F:.]\+\|\%(as\>\|range\>\)\@![A-Za-z_][A-Za-z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)\s*\%(%\s*\%('[0-9A-Za-z_.:-]\+'\|[A-Za-z0-9_.:-]\+\)\)\?\s\+\%(as\s\+\%([0-9]\+\|[A-Za-z_][A-Za-z0-9_]*\)\)\?" contains=bird2RoutingKw,bird2IPv4,bird2IPv6,bird2QuotedSymbol,bird2Variable,bird2Number
syn match  bird2NeighborTemplate "\<neighbor\>\s\+as\s\+\%([0-9]\+\|[A-Za-z_][A-Za-z0-9_]*\)\>" contains=bird2RoutingKw,bird2Structure,bird2SemanticModifier,bird2Variable,bird2Number
syn match  bird2NeighborRange "\<neighbor\>\s\+range\s\+[0-9a-fA-F:.\/]\+\%(\s\+as\s\+\%([0-9]\+\|[A-Za-z_][A-Za-z0-9_]*\)\)\?" contains=bird2RoutingKw,bird2IPv4,bird2IPv6,bird2Prefix,bird2Variable,bird2Number
syn match  bird2NeighborPort "\<neighbor\>\s\+\%([0-9a-fA-F:.]\+\|\%(as\>\|range\>\)\@![A-Za-z_][A-Za-z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)\%(\s*%\s*\%('[0-9A-Za-z_.:-]\+'\|[A-Za-z0-9_.:-]\+\)\)\?\%(\s\+as\s\+\%([0-9]\+\|[A-Za-z_][A-Za-z0-9_]*\)\)\?\s\+port\s\+\%([0-9]\+\|[A-Za-z_][A-Za-z0-9_]*\)\>" contains=bird2RoutingKw,bird2IPv4,bird2IPv6,bird2QuotedSymbol,bird2Variable,bird2Number
syn match  bird2NeighborRole "\<neighbor\>\s\+\%([0-9a-fA-F:.]\+\|\%(as\>\|range\>\)\@![A-Za-z_][A-Za-z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)\s\+\%(internal\|external\)\>" contains=bird2RoutingKw,bird2IPv4,bird2IPv6,bird2QuotedSymbol,bird2Variable,bird2SemanticModifier
syn match  bird2NeighborOnlink "\<neighbor\>\s\+\%([0-9a-fA-F:.]\+\|\%(as\>\|range\>\)\@![A-Za-z_][A-Za-z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)\s\+onlink\>" contains=bird2RoutingKw,bird2IPv4,bird2IPv6,bird2QuotedSymbol,bird2Variable
syn match  bird2SourceAddress "\<source address\>\s\+[0-9a-fA-F:.]\+" contains=bird2RoutingKw,bird2IPv4,bird2IPv6

" ------------------------
" Import/Export Statements (repository.import-export-statements)
" ------------------------
syn match  bird2ImportFilter "\<import\>\s\+filter\s\+\%([a-zA-Z_][a-zA-Z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)" contains=bird2Keyword,bird2FilterReference
syn region bird2ImportFilterInline matchgroup=bird2Keyword start="\<import\>\s\+filter\s*{" matchgroup=bird2Delimiter end="}" contains=@bird2All fold keepend
syn region bird2ExportWhere matchgroup=bird2Keyword start="\<export\>\s\+where\>" end=";" contains=@bird2All
syn region bird2ExportPrefilter matchgroup=bird2Keyword start="\<export\>\s\+in\>" end=";" contains=@bird2All
syn match  bird2ExportFilter "\<export\>\s\+filter\s\+\%([a-zA-Z_][a-zA-Z0-9_]*\|'[0-9A-Za-z_.:-]\+'\)" contains=bird2Keyword,bird2FilterReference

" ------------------------
" Print Statements (repository.print-statements)
" ------------------------
syn region bird2PrintStmt  matchgroup=bird2Keyword start="\<\%(print\|printn\)\>" end=";" contains=@bird2All

" ------------------------
" Core Keywords (used in definitions)
" ------------------------
syn keyword bird2Keyword    protocol template filter function import export

" ------------------------
" Structural Keywords (repository.structural-keywords)
" ------------------------
syn keyword bird2ControlFlow if then else case for do while break continue return in
syn match   bird2CaseElse   "\<else\s*:"
syn keyword bird2FlowControl accept reject error
syn keyword bird2Structure  table define include attribute eval ipv4 ipv6 local as from where cost limit action

" ------------------------
" Functional Keywords (repository.functional-keywords)
" ------------------------
" Protocol types
syn keyword bird2ProtocolTypeKw static rip ospf bgp babel rpki bfd bmp device direct kernel pipe perf mrt aggregator l3vpn radv bridge evpn
" Routing keywords
syn keyword bird2RoutingKw  graceful restart preference disabled hold keepalive connect retry start delay error wait forget scan randomize router id route neighbor provider customer rs_server rs_client
" Device keywords
syn keyword bird2DeviceKw   preferred
" Interface keywords
syn keyword bird2InterfaceKw interface type wired wireless tunnel rxcost limit hello update interval port tx class dscp priority rx buffer length check link rtt cost min max decay send timestamps
" RPKI keywords
syn keyword bird2RpkiKw      refresh retry expire transport ssh tcp user address version ignore private public key
syn match   bird2RpkiPhraseKw "\<\%(local\s\+address\|ignore\s\+max\s\+length\|min\s\+version\|max\s\+version\|bird\s\+private\s\+key\|remote\s\+public\s\+key\)\>"
" Authentication keywords
syn keyword bird2AuthKw     authentication none permissive password generate accept from to algorithm hmac cmac aes128 sha1 sha224 sha256 sha384 sha512 blake2s128 blake2s256 blake2b256 blake2b512 ao key keys secret deprecated preferred
" Time keyword
syn keyword bird2TimeKw     time
" Config keywords
syn keyword bird2ConfigKw   hostname description log syslog stderr udp cli bird protocols tables channels timeouts passwords bfd confederation cluster stub dead neighbors area md5 multihop passive rfc1583compat tick ls retransmit transmit ack state database summary external nssa translator always candidate never role stability election action warn warning auth bug fatal info trace block disable keep filtered receive modify add delete withdraw unreachable blackhole prohibit unreach igp_metric localpref med origin community large_community ext_community as_path prepend weight gateway scope onlink recursive multipath igp channel sadr src learn persist via ng threads thread group cork threshold settle digest fixed ping wakeup scheduling sockets allocator timers mrtdump timeformat preexport noexport exported stats count rpki reload all none master4
" Flowspec keywords
syn keyword bird2FlowspecKw flow4 flow6 dst src proto header dport sport icmp code tcp flags dscp dont_fragment is_fragment first_fragment last_fragment fragment label offset
" Address keywords
syn keyword bird2AddressKw  ipv4_mc ipv6_mc vpn4 vpn6 mpls aspa roa4 roa6 eth evpn neighbor pri sec
syn match   bird2AddressKw  "\<\%(ipv4-mpls\|ipv6-mpls\|ipv6-sadr\|vpn4-mc\|vpn4-mpls\|vpn6-mc\|vpn6-mpls\)\>"
syn match   bird2BfdPhraseKw "\<\%(strict\s\+bind\|zero\s\+udp6\s\+checksum\s\+rx\|idle\s\+tx\s\+interval\|express\s\+thread\s\+group\|multiplier\|keyed\|meticulous\)\>"
syn match   bird2BabelPhraseKw "\<\%(randomize\s\+router\s\+id\|show\s\+babel\s\+\%(interfaces\|neighbors\|entries\|routes\)\|send\s\+timestamps\|rtt\s\+\%(cost\|min\|max\|decay\)\|next\s\+hop\s\+\%(ipv4\|ipv6\|prefer\)\|extended\s\+next\s\+hop\|prefer\|native\)\>"
syn match   bird2BgpPhraseKw "\<\%(next\s\+hop\s\+\%(self\|address\|ibgp\|ebgp\)\|link\s\+local\s\+next\s\+hop\s\+format\%(\s\+\%(native\|single\|double\)\)\?\|import\s\+table\|export\s\+table\|base\s\+table\|add\s\+paths\|enable\s\+route\s\+refresh\|enable\s\+enhanced\s\+route\s\+refresh\|require\s\+route\s\+refresh\|require\s\+enhanced\s\+route\s\+refresh\|enable\s\+as4\|require\s\+as4\|enable\s\+extended\s\+messages\|require\s\+extended\s\+messages\|require\s\+hostname\|disable\s\+after\s\+error\|disable\s\+after\s\+cease\|enforce\s\+first\s\+as\|neighbor\s\+range\|interface\s\+range\|aigp\s\+originate\|min\s\+graceful\s\+restart\s\+time\|max\s\+graceful\s\+restart\s\+time\|graceful\s\+restart\s\+time\|require\s\+graceful\s\+restart\|require\s\+long\s\+lived\s\+graceful\s\+restart\|long\s\+lived\s\+graceful\s\+restart\|long\s\+lived\s\+stale\s\+time\|dynamic\s\+name\%(\s\+digits\)\?\|free\s\+bind\|ttl\s\+security\|multihop\s\+password\|local\s\+role\|require\s\+roles\|rr\s\+client\|rs\s\+client\|advertise\s\+hostname\|interpret\s\+communities\|deterministic\s\+med\|default\s\+bgp_local_pref\|default\s\+bgp_med\|med\s\+metric\|igp\s\+metric\|tx\s\+size\s\+warning\|missing\s\+lladdr\|gateway\s\+address\|forwarding\s\+addressed\|gateway\s\+recursive\|allow\s\+local\s\+as\|allow\s\+bogus\s\+as\|originate\s\+community\|full\s\+route\s\+table\|mandatory\|secondary\|validate\|capabilities\|primary\|aigp\|authentication\s\+ao\|send\s\+id\|recv\s\+id\|cmac\s\+aes128\|prefix\s\+limit\s\+hit\|administrative\s\+\%(shutdown\|reset\)\|peer\s\+deconfigured\|connection\s\+\%(rejected\|collision\)\|configuration\s\+change\|out\s\+of\s\+resources\|setkey\|drop\|single\|double\)\>"
syn match   bird2OspfPhraseKw "\<\%(link\s\+lsa\s\+suppression\|stub\s\+router\|graceful\s\+restart\s\+\%(aware\|time\)\|ecmp\s\+limit\|merge\s\+external\|rfc5838\|vpn\s\+pe\|instance\s\+id\|default\s\+\%(nssa\|cost2\?\)\|stub\s\+cost\|summary\|networks\|stubnet\|hidden\|translator\s\+stability\|virtual\s\+link\|transmit\s\+delay\|dead\s\+count\|poll\|type\s\+\%(bcast\|nbma\|pointopoint\|ptp\|ptmp\|pointomultipoint\)\|eligible\|real\s\+broadcast\|ptp\s\+\%(netmask\|address\)\|strict\s\+nonbroadcast\|rx\s\+buffer\s\+\%(normal\|large\)\|authentication\s\+simple\|show\s\+ospf\%(\s\+\%(interface\|neighbors\|topology\%(\s\+all\)\?\|state\%(\s\+all\)\?\|lsadb\%(\s\+\%(global\|area\|link\|type\|lsid\|self\|router\)\)\?\)\)\?\|ospf\s\+v[23]\|instance\|tag\|v2\|v3\|no\s\+summary\|real\s\+bdr\)\>"
syn match   bird2RipPhraseKw "\<\%(rip\s\+ng\|mode\s\+\%(multicast\|broadcast\)\|version\s\+only\|check\s\+zero\|update\s\+time\|timeout\s\+time\|garbage\s\+time\|retransmit\s\+time\|split\s\+horizon\|poison\s\+reverse\|demand\s\+circuit\|ecmp\s\+\%(limit\|weight\)\|infinity\|show\s\+rip\s\+\%(interfaces\|neighbors\)\|ttl\s\+security\s\+tx\s\+only\|authentication\s\+\%(plaintext\|cryptographic\)\|honor\s\+neighbor\|honor\s\+always\)\>"
syn match   bird2KernelPhraseKw "\<\%(merge\s\+paths\s\+limit\|merge\s\+paths\|kernel\s\+table\|netlink\s\+rx\s\+buffer\)\>"
syn match   bird2PipePhraseKw "\<\%(mode\s\+\%(opaque\|transparent\|GRE\)\)\>"
syn match   bird2StaticPhraseKw "\<\%(recursive\s\+mpls\|show\s\+static\|igp\s\+table\|check\s\+link\)\>"
syn match   bird2AuthPhraseKw "\<\%(authentication\s\+\%(none\|mac\%(\s\+permissive\)\?\|md5\|ao\)\|generate\s\+from\|generate\s\+to\|accept\s\+from\|accept\s\+to\)\>"
syn match   bird2ChannelLimitPhraseKw "\<\%(import\s\+limit\|export\s\+limit\)\>"
syn match   bird2SocketPhraseKw "\<\%(tx\s\+class\|tx\s\+dscp\|tx\s\+priority\)\>"
syn match   bird2InterfacePhraseKw "\<\%(rx\s\+buffer\|tx\s\+length\|check\s\+link\)\>"
syn match   bird2DiagnosticsPhraseKw "\<\%(debug\s\+latency\s\+limit\|debug\s\+latency\|debug\s\+show\s\+route\|debug\s\+protocols\|debug\s\+channels\|debug\s\+tables\|debug\s\+commands\|debug\s\+all\|debug\s\+\%(events\|filters\|interfaces\|off\|packets\|routes\|states\)\|debug\|watchdog\s\+warning\|watchdog\s\+timeout\|states\|routes\|filters\|interfaces\|events\|packets\|messages\)\>"
syn match   bird2TablePhraseKw "\<\%(min\s\+settle\s\+time\|max\s\+settle\s\+time\|gc\s\+threshold\|gc\s\+period\|export\s\+settle\s\+time\|sorted\|trie\|roa\)\>"
syn match   bird2AggregatorPhraseKw "\<\%(peer\s\+table\|aggregate\s\+on\|merge\s\+by\)\>"
syn match   bird2VpnPhraseKw "\<\%(route\s\+distinguisher\|import\s\+target\|export\s\+target\|route\s\+target\)\>"
syn match   bird2EvpnPhraseKw "\<\%(encapsulation\s\+vxlan\|vlan\s\+filtering\|vlan\s\+range\|vni\|vid\|bridge\s\+device\|kbr\s\+source\|tunnel\s\+device\|router\s\+address\|evpn\s\+\%(ead\|mac\|imet\|es\)\|tag\)\>"
syn match   bird2BmpPhraseKw "\<\%(monitoring\s\+rib\s\+in\s\+pre_policy\|monitoring\s\+rib\s\+in\s\+post_policy\|system\s\+description\|system\s\+name\|tx\s\+buffer\s\+limit\|station\s\+address\|station\)\>"
syn match   bird2RadvPhraseKw "\<\%(solicited\s\+ra\s\+unicast\|router\s\+discovery\|min\s\+ra\s\+interval\|max\s\+ra\s\+interval\|min\s\+delay\|link\s\+mtu\|default\s\+lifetime\|route\s\+lifetime\|default\s\+preference\|route\s\+preference\|prefix\s\+linger\s\+time\|route\s\+linger\s\+time\|current\s\+hop\s\+limit\|propagate\s\+routes\|other\s\+config\|reachable\s\+time\|retrans\s\+timer\|valid\s\+lifetime\|preferred\s\+lifetime\|lifetime\s\+mult\|pd\s\+preferred\|rdnss\s\+local\|dnssl\s\+local\|custom\s\+option\s\+type\|custom\s\+option\s\+local\|managed\|trigger\|sensitive\|autonomous\|skip\|low\|medium\|high\)\>"
syn match   bird2AspaPhraseKw "\<\%(aspa\s\+providers\|transit\s\+providers\|route\s\+aspa\)\>"
syn match   bird2FlowspecPhraseKw "\<\%(next\s\+header\|icmp\s\+type\|icmp\s\+code\|tcp\s\+flags\)\>"
syn match   bird2ThreadingPhraseKw "\<\%(thread\s\+group\|show\s\+threads\s\+all\|show\s\+threads\|cork\s\+threshold\|route\s\+refresh\s\+export\s\+settle\s\+time\|digest\s\+settle\s\+time\|filter\s\+stacks\|max\s\+generation\)\>"
syn match   bird2MrtPhraseKw "\<\%(always\s\+add\s\+path\|filename\)\>"
syn match   bird2PerfPhraseKw "\<\%(mode\s\+\%(import\|export\)\|exp\s\+\%(from\|to\)\|threshold\s\+\%(min\|max\)\|repeat\)\>"
syn match   bird2OperationsPhraseKw "\<\%(router\s\+id\s\+from\|graceful\s\+restart\s\+wait\|vrf\s\+default\|receive\s\+limit\|import\s\+keep\s\+filtered\|export\s\+in\|rpki\s\+reload\|mrtdump\s\+protocols\)\>"
syn match   bird2CliShowPhraseKw "\<\%(show\s\+status\|show\s\+protocols\s\+all\|show\s\+protocols\|show\s\+interfaces\s\+summary\|show\s\+interfaces\|show\s\+symbols\s\+\%(table\|filter\|function\|protocol\|template\|roa\)\|show\s\+symbols\|show\s\+route\s\+\%(for\|in\|table\|filter\|where\|all\|primary\|filtered\|import\|export\|exported\|preexport\|noexport\|protocol\|stats\|count\)\|show\s\+bfd\s\+sessions\s\+\%(address\|direct\|multihop\|interface\|dev\|all\|ipv4\|ipv6\)\|show\s\+bfd\s\+sessions\|show\s\+mpls\s\+ranges\|show\s\+memory\)\>"
syn match   bird2CliReloadPhraseKw "\<\%(reload\s\+filters\s\+in\|reload\s\+filters\s\+out\|reload\s\+filters\|reload\s\+bgp\s\+in\|reload\s\+bgp\s\+out\|reload\s\+bgp\|reload\s\+in\|reload\s\+out\)\>"
syn match   bird2CliReloadModifierKw "\<partial\>"
syn match   bird2CliDumpPhraseKw "\<\%(dump\s\+tables\|dump\s\+attribute\s\+stats\|dump\s\+ao\s\+keys\|dump\s\+filter\s\+all\|dump\s\+resources\|dump\s\+sockets\|dump\s\+events\|dump\s\+interfaces\|dump\s\+neighbors\|dump\s\+attributes\|dump\s\+routes\|dump\s\+protocols\|mrt\s\+dump\s\+table\|mrt\s\+dump\s\+where\|mrt\s\+dump\s\+to\|mrt\s\+dump\s\+filter\|mrt\s\+dump\|timeformat\s\+route\|timeformat\s\+protocol\|timeformat\s\+base\|timeformat\s\+log\|timeformat\s\+iso\|configure\s\+soft\s\+timeout\|configure\s\+soft\|configure\s\+timeout\|configure\s\+confirm\|configure\s\+undo\|configure\s\+status\|configure\s\+check\|restrict\|echo\|enable\|disable\|restart\|mrtdump\|quit\|exit\|help\)\>"
syn match   bird2CliControlPhraseKw "\<\%(configure\|down\|graceful\s\+restart\|timeformat\s\+\%(short\|long\|ms\|us\)\)\>"

" ------------------------
" Semantic Modifiers (repository.semantic-modifiers)
" ------------------------
syn keyword bird2SemanticModifier self on off remote extended native ipv6 internal external

" ------------------------
" Built-in Functions (repository.builtin-functions)
" ------------------------
syn keyword bird2BuiltinFunc defined unset roa_check aspa_check aspa_check_downstream aspa_check_upstream from_hex format append prepend add delete empty reset bt_assert bt_check_assign bt_test_suite bt_test_same

" ------------------------
" Method Properties (repository.method-properties)
" ------------------------
syn keyword bird2Property   first last last_nonaggregated len asn data data1 data2 is_v4 ip src dst rd maxlen type mask min max mac vlan_id evpn_type evpn_tag evpn_esi router_ip contained

" ------------------------
" Route Attributes (repository.route-attributes)
" ------------------------
syn keyword bird2RouteAttr  net scope preference from gw proto source dest ifname ifindex weight gw_mpls gw_mpls_stack onlink igp_metric local_metric nexthop hostentry flowspec_valid aspa_providers roa_aggregated mpls_label mpls_policy mpls_class bgp_path bgp_origin bgp_next_hop bgp_med bgp_local_pref bgp_community bgp_ext_community bgp_large_community bgp_originator_id bgp_cluster_list bgp_atomic_aggr bgp_aggregator bgp_aigp bgp_pmsi_tunnel bgp_otc bgp_mpls_label_stack bgp_mp_reach_nlri bgp_mp_unreach_nlri bgp_as4_path bgp_as4_aggregator ospf_metric1 ospf_metric2 ospf_tag ospf_router_id rip_metric rip_tag rip_from babel_metric babel_router_id babel_seqno radv_preference radv_lifetime ra_preference ra_lifetime krt_source krt_metric krt_prefsrc krt_realm krt_scope krt_mtu krt_window krt_rtt krt_rttvar krt_ssthresh krt_sstresh krt_cwnd krt_advmss krt_reordering krt_hoplimit krt_initcwnd krt_rto_min krt_initrwnd krt_quickack krt_congctl krt_fastopen_no_cookie krt_lock_mtu krt_lock_window krt_lock_rtt krt_lock_rttvar krt_lock_ssthresh krt_lock_sstresh krt_lock_cwnd krt_lock_advmss krt_lock_reordering krt_lock_hoplimit krt_lock_initcwnd krt_lock_rto_min krt_lock_initrwnd krt_lock_quickack krt_lock_congctl krt_lock_fastopen_no_cookie krt_feature_allfrag krt_feature_ecn kbr_source iface_type iface_bridge_vlan_filtering iface_vxlan_id iface_vxlan_learning iface_vxlan_ip_addr mypath mylclist
syn match   bird2RouteAttr  "\<bgp_unknown_0x[0-9a-fA-F]\{2}\>"
syn keyword bird2RuntimeAttr proto_name proto_protocol_name proto_protocol_type proto_main_table_id proto_state proto_last_modified proto_info proto_proto_id ea_proto_channel_list proto_channel_id channel_in_keep rtable proto_bgp_rem_id proto_bgp_rem_as proto_bgp_loc_as proto_bgp_rem_ip bgp_afi bgp_peer_type bgp_extended_next_hop bgp_add_path_rx bgp_in_conn_local_open_msg bgp_in_conn_remote_open_msg bgp_out_conn_local_open_msg bgp_out_conn_remote_open_msg bgp_in_conn_state bgp_out_conn_state bgp_in_conn_sk bgp_out_conn_sk bgp_state_startup bgp_close_bmp bgp_as4_session bgp_as4_in_conn bgp_as4_out_conn

" ------------------------
" Data Types (repository.data-types)
" ------------------------
syn match   bird2Type       "\<\%(\%(int\|pair\|quad\|ip\|prefix\|mac\|ec\|lc\|rd\|enum\)\s\+set\|int\|bool\|ip\|prefix\|mac\|rd\|pair\|quad\|ec\|lc\|string\|bytestring\|bgpmask\|bgppath\|clist\|eclist\|lclist\|set\|enum\|route\)\>"

" ------------------------
" Operators (repository.operators)
" ------------------------
syn match  bird2Comparison  "!\~\|==\|!=\|<=\|>=\|=\|<\|>\|\~"
syn match  bird2Logical     "&&\|||\|->\|!"
syn match  bird2Bitwise     "\%(&\)\@<!&\%(&\)\@!\|\%(|\)\@<!|\%(|\)\@!"
syn match  bird2Concat      "++"
syn match  bird2Range       "\.\."
syn match  bird2Arithmetic  "\%(+\ze[^+]\|-\ze[^>]\|\*\|/\|%\)"
syn match  bird2Accessor    "\."

" ------------------------
" Constants (repository.constants)
" ------------------------
" Boolean constants
syn keyword bird2BoolConst  on off yes no true false
" Special constants
syn keyword bird2SpecialConst empty unknown generic rt ro one ten
" Scope constants
syn keyword bird2ScopeConst SCOPE_HOST SCOPE_LINK SCOPE_SITE SCOPE_ORGANIZATION SCOPE_UNIVERSE SCOPE_UNDEFINED
" Source constants
syn keyword bird2SourceConst RTS_STATIC RTS_INHERIT RTS_DEVICE RTS_STATIC_DEVICE RTS_REDIRECT RTS_RIP RTS_OSPF RTS_OSPF_IA RTS_OSPF_EXT1 RTS_OSPF_EXT2 RTS_BGP RTS_PIPE RTS_BABEL RTS_RPKI RTS_L3VPN RTS_AGGREGATED RTS_BRIDGE RTS_EVPN
" Destination constants
syn keyword bird2DestConst  RTD_UNICAST RTD_ROUTER RTD_DEVICE RTD_MULTIPATH RTD_BLACKHOLE RTD_UNREACHABLE RTD_PROHIBIT
" ROA constants
syn keyword bird2RoaConst   ROA_UNKNOWN ROA_INVALID ROA_VALID
" ASPA constants
syn keyword bird2AspaConst  ASPA_UNKNOWN ASPA_INVALID ASPA_VALID
" BGP origin constants
syn keyword bird2BgpOriginConst ORIGIN_IGP ORIGIN_EGP ORIGIN_INCOMPLETE
" RA preference constants
syn keyword bird2RaPreferenceConst RA_PREF_LOW RA_PREF_MEDIUM RA_PREF_HIGH
" Address family constants
syn keyword bird2AddressFamilyConst AF_IPV4 AF_IPV6
" Bridge source constants
syn keyword bird2BridgeSourceConst KBR_SRC_BIRD KBR_SRC_LOCAL KBR_SRC_STATIC KBR_SRC_DYNAMIC
" Net type constants
syn keyword bird2NetConst   NET_IP4 NET_IP6 NET_IP6_SADR NET_VPN4 NET_VPN6 NET_ROA4 NET_ROA6 NET_FLOW4 NET_FLOW6 NET_MPLS NET_ASPA NET_ETH NET_EVPN NET_EVPN_EAD NET_EVPN_MAC NET_EVPN_IMET NET_EVPN_ES NET_NEIGHBOR
" MPLS constants
syn keyword bird2MplsConst  MPLS_POLICY_NONE MPLS_POLICY_STATIC MPLS_POLICY_PREFIX MPLS_POLICY_AGGREGATE MPLS_POLICY_VRF

" ------------------------
" Filter Names (repository.filter-names)
" ------------------------
syn match  bird2FilterReference "[a-zA-Z_][a-zA-Z0-9_]*_filter\>"

" ------------------------
" User Variables (repository.user-variables)
" ------------------------
syn match  bird2UserVariable "[A-Z][a-zA-Z0-9_]*\>"

" ------------------------
" Function Calls (repository.function-calls)
" ------------------------
syn match  bird2FunctionCall "[a-zA-Z_][a-zA-Z0-9_]*\ze\s*(" contains=bird2BuiltinFunc

" ------------------------
" Method Calls (repository.method-calls)
" ------------------------
syn match  bird2MethodCall  "\.\s*[a-zA-Z_][a-zA-Z0-9_]*\s*(" contains=bird2Accessor
syn match  bird2PropertyAccess "\.\s*[a-zA-Z_][a-zA-Z0-9_]*\%(\s*(\)\@!" contains=bird2Accessor,bird2Property

" ------------------------
" Variable Declarations (repository.variable-declarations)
" ------------------------
syn match  bird2VarDecl     "\<\%(\%(int\|pair\|quad\|ip\|prefix\|mac\|ec\|lc\|rd\|enum\)\s\+set\|int\|bool\|ip\|prefix\|mac\|rd\|pair\|quad\|ec\|lc\|string\|bytestring\|bgpmask\|bgppath\|clist\|eclist\|lclist\|set\|enum\|route\)\>\s\+[a-zA-Z_][a-zA-Z0-9_]*\s*\%(=\|;\)" contains=bird2Type,bird2Variable

" ------------------------
" Blocks & Delimiters (repository.blocks)
" ------------------------
syn match  bird2Delimiter   "[{}()\[\];,]"

" ------------------------
" Cluster for all patterns
" ------------------------
syn cluster bird2All contains=bird2Comment,bird2String,bird2QuotedSymbol,bird2Escape,bird2HexNumber,bird2Number,bird2TimeUnit,bird2IPv4,bird2IPv6,bird2VpnRD,bird2ByteString,bird2BgpPath,bird2BgpWildcard,bird2ASN,bird2Prefix,bird2FilterDef,bird2FunctionDef,bird2TemplateDef,bird2ProtocolDefWithTemplate,bird2ProtocolDefWithName,bird2ProtocolDefAnonymous,bird2NextHopIPv4,bird2NextHopIPv6,bird2NextHopSelf,bird2ExtendedNextHop,bird2NextHopPrefer,bird2NextHopKeep,bird2NextHopAddr,bird2RequireExtNexthop,bird2LocalAsStmt,bird2LocalAsTemplate,bird2NeighborStmt,bird2NeighborTemplate,bird2NeighborRange,bird2NeighborPort,bird2NeighborRole,bird2NeighborOnlink,bird2SourceAddress,bird2ImportFilter,bird2ImportFilterInline,bird2ExportWhere,bird2ExportPrefilter,bird2ExportFilter,bird2PrintStmt,bird2ControlFlow,bird2CaseElse,bird2FlowControl,bird2Structure,bird2ProtocolTypeKw,bird2RoutingKw,bird2DeviceKw,bird2InterfaceKw,bird2RpkiKw,bird2RpkiPhraseKw,bird2AuthKw,bird2TimeKw,bird2ConfigKw,bird2FlowspecKw,bird2AddressKw,bird2BfdPhraseKw,bird2BabelPhraseKw,bird2BgpPhraseKw,bird2OspfPhraseKw,bird2RipPhraseKw,bird2KernelPhraseKw,bird2PipePhraseKw,bird2StaticPhraseKw,bird2AuthPhraseKw,bird2ChannelLimitPhraseKw,bird2SocketPhraseKw,bird2InterfacePhraseKw,bird2DiagnosticsPhraseKw,bird2TablePhraseKw,bird2AggregatorPhraseKw,bird2VpnPhraseKw,bird2EvpnPhraseKw,bird2BmpPhraseKw,bird2RadvPhraseKw,bird2AspaPhraseKw,bird2FlowspecPhraseKw,bird2ThreadingPhraseKw,bird2MrtPhraseKw,bird2PerfPhraseKw,bird2OperationsPhraseKw,bird2CliShowPhraseKw,bird2CliReloadPhraseKw,bird2CliReloadModifierKw,bird2CliDumpPhraseKw,bird2CliControlPhraseKw,bird2SemanticModifier,bird2BuiltinFunc,bird2Property,bird2RouteAttr,bird2RuntimeAttr,bird2Type,bird2Comparison,bird2Logical,bird2Bitwise,bird2Concat,bird2Arithmetic,bird2Range,bird2Accessor,bird2BoolConst,bird2SpecialConst,bird2ScopeConst,bird2SourceConst,bird2DestConst,bird2RoaConst,bird2AspaConst,bird2BgpOriginConst,bird2RaPreferenceConst,bird2AddressFamilyConst,bird2BridgeSourceConst,bird2NetConst,bird2MplsConst,bird2FilterReference,bird2UserVariable,bird2FunctionCall,bird2MethodCall,bird2PropertyAccess,bird2VarDecl,bird2Variable,bird2Delimiter,bird2Keyword

" ------------------------
" Links to default highlight groups
" ------------------------
hi def link bird2Comment          Comment
hi def link bird2String           String
hi def link bird2QuotedSymbol     Identifier
hi def link bird2Escape           SpecialChar
hi def link bird2HexNumber        Number
hi def link bird2Number           Number
hi def link bird2TimeUnit         Number
hi def link bird2IPv4             Constant
hi def link bird2IPv6             Constant
hi def link bird2VpnRD            Constant
hi def link bird2ByteString       Constant
hi def link bird2BgpPath          Special
hi def link bird2BgpWildcard      Special
hi def link bird2ASN              Number
hi def link bird2Prefix           Constant

hi def link bird2FilterDef        Structure
hi def link bird2FilterName       Function
hi def link bird2FilterBody       Normal
hi def link bird2FunctionDef      Structure
hi def link bird2FunctionName     Function
hi def link bird2FunctionParams   Normal
hi def link bird2ReturnType       Operator
hi def link bird2FunctionBody     Normal
hi def link bird2TemplateDef      Structure
hi def link bird2ProtocolType     Type
hi def link bird2TemplateName     Function
hi def link bird2TemplateBody     Normal
hi def link bird2ProtocolDefWithTemplate Structure
hi def link bird2ProtocolDefWithName Structure
hi def link bird2ProtocolDefAnonymous Structure
hi def link bird2ProtocolName     Function
hi def link bird2ProtocolBody     Normal

hi def link bird2NextHopIPv4      Statement
hi def link bird2NextHopIPv6      Statement
hi def link bird2NextHopSelf      Statement
hi def link bird2ExtendedNextHop  Statement
hi def link bird2NextHopPrefer    Statement
hi def link bird2NextHopKeep      Statement
hi def link bird2NextHopAddr      Statement
hi def link bird2RequireExtNexthop Statement
hi def link bird2LocalAsStmt      Statement
hi def link bird2LocalAsTemplate  Statement
hi def link bird2NeighborStmt     Statement
hi def link bird2NeighborTemplate Statement
hi def link bird2NeighborRange    Statement
hi def link bird2NeighborPort     Statement
hi def link bird2NeighborRole     Statement
hi def link bird2NeighborOnlink   Statement
hi def link bird2SourceAddress    Statement
hi def link bird2ImportFilter     Statement
hi def link bird2ImportFilterInline Statement
hi def link bird2ExportWhere      Statement
hi def link bird2ExportPrefilter  Statement
hi def link bird2ExportFilter     Statement
hi def link bird2PrintStmt        Statement

hi def link bird2ControlFlow      Statement
hi def link bird2CaseElse         Statement
hi def link bird2FlowControl      Statement
hi def link bird2Structure        Keyword
hi def link bird2Keyword          Keyword
hi def link bird2ProtocolTypeKw   Keyword
hi def link bird2RoutingKw        Keyword
hi def link bird2DeviceKw         Keyword
hi def link bird2InterfaceKw      Keyword
hi def link bird2RpkiKw           Keyword
hi def link bird2RpkiPhraseKw     Keyword
hi def link bird2AuthKw           Keyword
hi def link bird2TimeKw           Keyword
hi def link bird2ConfigKw         Keyword
hi def link bird2FlowspecKw       Keyword
hi def link bird2AddressKw        Keyword
hi def link bird2BfdPhraseKw      Keyword
hi def link bird2BabelPhraseKw    Keyword
hi def link bird2BgpPhraseKw      Keyword
hi def link bird2OspfPhraseKw     Keyword
hi def link bird2RipPhraseKw      Keyword
hi def link bird2KernelPhraseKw   Keyword
hi def link bird2PipePhraseKw     Keyword
hi def link bird2StaticPhraseKw   Keyword
hi def link bird2AuthPhraseKw     Keyword
hi def link bird2ChannelLimitPhraseKw Keyword
hi def link bird2SocketPhraseKw   Keyword
hi def link bird2InterfacePhraseKw Keyword
hi def link bird2DiagnosticsPhraseKw Keyword
hi def link bird2TablePhraseKw    Keyword
hi def link bird2AggregatorPhraseKw Keyword
hi def link bird2VpnPhraseKw      Keyword
hi def link bird2EvpnPhraseKw     Keyword
hi def link bird2BmpPhraseKw      Keyword
hi def link bird2RadvPhraseKw     Keyword
hi def link bird2AspaPhraseKw     Keyword
hi def link bird2FlowspecPhraseKw Keyword
hi def link bird2ThreadingPhraseKw Keyword
hi def link bird2MrtPhraseKw      Keyword
hi def link bird2PerfPhraseKw     Keyword
hi def link bird2OperationsPhraseKw Keyword
hi def link bird2CliShowPhraseKw  Keyword
hi def link bird2CliReloadPhraseKw Keyword
hi def link bird2CliReloadModifierKw Keyword
hi def link bird2CliDumpPhraseKw  Keyword
hi def link bird2CliControlPhraseKw Keyword
hi def link bird2SemanticModifier Keyword

hi def link bird2BuiltinFunc      Function
hi def link bird2Property         Identifier
hi def link bird2RouteAttr        Identifier
hi def link bird2RuntimeAttr      Identifier
hi def link bird2Type             Type

hi def link bird2Comparison       Operator
hi def link bird2Logical          Operator
hi def link bird2Bitwise          Operator
hi def link bird2Concat           Operator
hi def link bird2Arithmetic       Operator
hi def link bird2Range            Operator
hi def link bird2Accessor         Delimiter

hi def link bird2BoolConst        Constant
hi def link bird2SpecialConst     Constant
hi def link bird2ScopeConst       Constant
hi def link bird2SourceConst      Constant
hi def link bird2DestConst        Constant
hi def link bird2RoaConst         Constant
hi def link bird2AspaConst        Constant
hi def link bird2BgpOriginConst   Constant
hi def link bird2RaPreferenceConst Constant
hi def link bird2AddressFamilyConst Constant
hi def link bird2BridgeSourceConst Constant
hi def link bird2NetConst         Constant
hi def link bird2MplsConst        Constant

hi def link bird2FilterReference  Function
hi def link bird2UserVariable     Identifier
hi def link bird2FunctionCall     Function
hi def link bird2MethodCall       Function
hi def link bird2PropertyAccess   Identifier
hi def link bird2VarDecl          Identifier
hi def link bird2Variable         Normal
hi def link bird2Delimiter        Delimiter

" ------------------------
" Folding markers
" ------------------------
syn sync fromstart
setlocal foldmethod=syntax

let b:current_syntax = 'bird2'

" vim: ts=2 sw=2 et
