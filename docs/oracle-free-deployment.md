# Oracle Cloud Always Free deployment (Nuvio fork)

This deployment targets an OCI Ampere A1 ARM64 VM using only Always Free eligible resources.

## Resource guardrails

- Create one VM.Standard.A1.Flex instance with **2 OCPUs and 12 GB RAM maximum** (or a smaller allocation).
- Use an Ubuntu ARM64 image marked Always Free Eligible.
- Keep the boot volume and any extra block volumes within the tenancy's **200 GB combined Always Free allocation**.
- Do not create paid compute, paid storage, paid load balancers, or upgrade the tenancy.
- Always Free compute is available only in the tenancy's home region. Choose the home region carefully during signup.

## Deploy

1. Provision the eligible ARM64 VM and assign a public IPv4 address.
2. Configure the VCN security list or network security group to allow TCP 22 from your own IP, and TCP 3232 from the clients that need to reach the addon. Do not expose SSH to the whole internet if avoidable.
3. SSH into the VM and install Docker Engine plus the Docker Compose plugin using Docker's official Ubuntu instructions.
4. Clone this repository and select the `oracle-free-migration` branch:
   ```sh
   git clone --branch oracle-free-migration https://github.com/dobinmathew-beep/aiometadata-nuvio-edition.git
   cd aiometadata-nuvio-edition
   ```
5. Build and start the service:
   ```sh
   docker compose -f docker-compose.oracle-free.yml up -d --build
   ```
6. Check health and logs:
   ```sh
   docker compose -f docker-compose.oracle-free.yml ps
   docker compose -f docker-compose.oracle-free.yml logs --tail=100 aiometadata
   ```
7. Test `http://YOUR_VM_PUBLIC_IP:3232/health/live`, then configure the addon in Nuvio using the public endpoint.

## Persistence and limitations

- SQLite is stored in the named Docker volume `aiometadata-nuvio-data` mounted at `/data`, so it survives container replacement and VM reboots as long as the volume/boot disk is retained.
- Valkey 9 runs inside the application container and is an ephemeral cache. It is rebuilt after container restarts; metadata can be fetched and cached again.
- Back up the Docker volume regularly. A VM or boot-volume deletion can still destroy data.
- Oracle can reclaim idle Always Free compute instances when all documented utilization thresholds remain below 20% over a seven-day period. Always Free has no SLA, and A1 capacity may be unavailable in the selected home region.
- This initial setup exposes the application on TCP 3232. Add a domain and HTTPS reverse proxy before treating it as a public production endpoint.

## Cost safety

Before creating any resource, confirm the Console labels it **Always Free Eligible**. Do not select paid shapes or paid add-ons. Do not upgrade the account. If the Console cannot offer an eligible A1 VM in the home region, stop rather than substituting a paid shape.
