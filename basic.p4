#include <core.p4>
#include <v1model.p4>

// Definição de cabeçalhos
header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

// Structs para cabeçalhos e metadados
struct headers {
    ethernet_t ethernet;
    ipv4_t     ipv4;
}

struct metadata {
}

// Parser
parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {
    state start {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            0x0800: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition accept;
    }
}

// Verificação de checksum (vazia)
control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply { }
}

// Cálculo de checksum (vazio)
control MyComputeChecksum(inout headers hdr, inout metadata meta) {
    apply { }
}

// Encaminhamento
control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    action ipv4_forward(bit<48> dstMac, bit<9> port) {
        hdr.ethernet.dstAddr = dstMac;
        hdr.ethernet.srcAddr = 0x000000000001;
        standard_metadata.egress_spec = port;
    }

    action drop() {
        mark_to_drop(standard_metadata);
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
        }
        size = 1024;
    }

    apply {
        ipv4_lpm.apply();
    }
}



// Egress (vazio)
control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply { }
}

// Deparser
control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
    }
}

// Pipeline principal
V1Switch(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;

