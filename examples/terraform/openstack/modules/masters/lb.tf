resource "openstack_lb_loadbalancer_v2" "lb_ucp" {
  name = "${var.cluster_name}-ucp"
  vip_subnet_id = var.internal_subnet_id
}

resource "openstack_lb_listener_v2" "lb_list_ucp" {
  name = "${var.cluster_name}-ucp-443"
  protocol = "TCP"
  protocol_port = 443
  loadbalancer_id = openstack_lb_loadbalancer_v2.lb_ucp.id
}

resource "openstack_lb_pool_v2" "lb_pool_ucp" {
  name = "${var.cluster_name}-ucp-443"
  protocol = "TCP"
  lb_method = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.lb_list_ucp.id
}

resource "openstack_lb_member_v2" "lb_member_ucp" {
  count = var.master_count
  pool_id = openstack_lb_pool_v2.lb_pool_ucp.id
  protocol_port = 443
  address = element(openstack_compute_instance_v2.docker-master.*.network.0.fixed_ip_v4, count.index)
  subnet_id = var.internal_subnet_id
}

resource "openstack_networking_floatingip_v2" "master_lb_vip" {
  pool              = var.external_network_name
}

resource "openstack_networking_floatingip_associate_v2" "master_vip" {
  floating_ip = openstack_networking_floatingip_v2.master_lb_vip.address
  port_id = openstack_lb_loadbalancer_v2.lb_ucp.vip_port_id
}


resource "openstack_lb_listener_v2" "lb_list_ucp2" {
  protocol = "TCP"
  name = "${var.cluster_name}-ucp-6443"
  protocol_port = 6443
  loadbalancer_id = openstack_lb_loadbalancer_v2.lb_ucp.id
}

resource "openstack_lb_pool_v2" "lb_pool_ucp2" {
  protocol = "TCP"
  name = "${var.cluster_name}-ucp-6443"
  lb_method = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.lb_list_ucp2.id
}

resource "openstack_lb_member_v2" "lb_member_ucp2" {
  count = var.master_count
  pool_id = openstack_lb_pool_v2.lb_pool_ucp2.id
  protocol_port = 6443
  address = element(openstack_compute_instance_v2.docker-master.*.network.0.fixed_ip_v4, count.index)
  subnet_id = var.internal_subnet_id
}

# TODO: Change to http check (GA)
resource "openstack_lb_monitor_v2" "ucp" {
  pool_id     = openstack_lb_pool_v2.lb_pool_ucp.id
  type        = "PING"
  delay       = 20
  timeout     = 10
  max_retries = 3
}
