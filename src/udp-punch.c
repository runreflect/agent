#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/udp.h>

unsigned short checksum(unsigned short *buf, int len) {
  unsigned long sum;

  for(sum = 0; len > 0; len--) {
    sum += *buf++;
  }

  sum = (sum >> 16) + (sum & 0xffff);
  sum += (sum >> 16);
  return (unsigned short)(~sum);
}

int main(int argc, char const *argv[]) {
  int enabled = 1;
  char buffer[1024];
  memset(buffer, 0, 1024);

  struct iphdr *ip = (struct iphdr *) buffer;
  struct udphdr *udp = (struct udphdr *) (buffer + sizeof(struct iphdr));

  // Validate arguments.
  if (argc < 5) {
    printf("Usage: %s <source IP> <source port> <destination IP> <target port>\n", argv[0]);
    return EXIT_FAILURE;
  }

  uint32_t src_addr = inet_addr(argv[1]);
  uint16_t src_port = atoi(argv[2]);
  uint32_t dst_addr = inet_addr(argv[3]);
  uint16_t dst_port = atoi(argv[4]);

  // Create and configure the socket.
  int socket_fd;
  if ((socket_fd = socket(PF_INET, SOCK_RAW, IPPROTO_UDP)) < 0) {
    perror("Failed to create IP socket");
    return EXIT_FAILURE;
  }

  if(setsockopt(socket_fd, IPPROTO_IP, IP_HDRINCL, &enabled, sizeof(enabled)) < 0) {
    perror("Failed to configure header includes on the socket");
    return EXIT_FAILURE;
  }

  // Construct the IP and UDP packet headers.
  ip->ihl = 5;
  ip->version = 4;
  ip->tos = 16; // low delay
  ip->tot_len = sizeof(struct iphdr) + sizeof(struct udphdr);
  ip->id = htons(11637);
  ip->ttl = 64;
  ip->protocol = 17; // UDP
  ip->saddr = src_addr;
  ip->daddr = dst_addr;

  udp->uh_sport = htons(src_port);
  udp->uh_dport = htons(dst_port);
  udp->uh_ulen = htons(sizeof(struct udphdr));

  ip->check = checksum((unsigned short *)buffer, ip->tot_len);

  // Send the datagram to the destination.
  struct sockaddr_in sin;
  sin.sin_family = AF_INET;
  sin.sin_port = htons(dst_port);
  sin.sin_addr.s_addr = dst_addr;

  if (sendto(socket_fd, buffer, ip->tot_len, 0, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
    perror("Failed to send datagram");
    return EXIT_FAILURE;
  }

  printf("Datagram sent\n");

  // Cleanup.
  close(socket_fd);

  return EXIT_SUCCESS;
}

