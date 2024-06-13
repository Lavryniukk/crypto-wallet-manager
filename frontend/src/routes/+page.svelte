<script lang="ts">
	import type { HDNodeWallet } from 'ethers';
	import type { Wallet } from 'ethers';
	import { address } from '$lib/contract/address';
	import { abi } from '$lib/contract/abi';
	import { ethers } from 'ethers';

	function weiToEth(wei: string) {
		return ethers.formatEther(wei);
	}

	let wallet: null | HDNodeWallet = $state(null);
	let contract: null | ethers.Contract = $state(null);
	let balance: Promise<number> = $state(Promise.resolve(0));
	$effect(() => {
		const { ethereum } = window as unknown as { ethereum?: ethers.Eip1193Provider };
		if (!ethereum) {
			return;
		}
		const provider = new ethers.BrowserProvider(ethereum);
		provider.getSigner().then((s) => {
			contract = new ethers.Contract(address, abi, s);
			balance = contract.getBalance();
		});
	});

	const refreshBalance = async () => {
		balance = contract?.getBalance() as Promise<number>;
	};

	const deposit = async () => {
		if (contract) {
			const tx = await contract.deposit({ value: ethers.parseUnits('10', 'ether') });
			await tx.wait();
			await refreshBalance();
		}
	};

	const withdraw = async () => {
		if (contract) {
			const b = await balance;
			const tx = await contract.withdraw(b.toString());
			await tx.wait();
			await refreshBalance();
		}
	};

	const generateWallet = () => {
		wallet = ethers.Wallet.createRandom();
		console.log(wallet);
	};
</script>

<main class="w-screen h-screen bg-zinc-200 flex items-center flex-col justify-center">
	<button onclick={generateWallet} class="button">Generate wallet</button>
	{#if wallet}
		<div class="mt-4">
			<p>Address: {wallet.address}</p>
			<p>Public key: {wallet.publicKey}</p>
			<p>Private key: {wallet.privateKey}</p>
		</div>
	{/if}
	{#if contract}
		<button class="button" onclick={refreshBalance}>refresh balance</button>
		<button class="button" onclick={deposit}>deposit</button>
		<button class="button" onclick={withdraw}>Withdraw</button>
		{#await balance}
			<p>Balance: Loading...</p>
		{:then b}
			<p>Balance: {b.toString()}</p>
		{/await}
	{/if}
</main>

<style lang="postcss">
	.button {
		@apply py-1 bg-emerald-400 hover:opacity-80 rounded-md px-3;
	}
</style>
