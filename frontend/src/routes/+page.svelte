<script lang="ts">
	import type { HDNodeWallet } from 'ethers';
	import { address } from '$lib/contract/address';
	import { abi } from '$lib/contract/abi';
	import { ethers } from 'ethers';

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
			console.log(tx);
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
</script>

<main class="w-screen h-screen bg-zinc-200 flex items-center flex-col justify-center">
	{#if contract}
		<div class="p-3 flex flex-col gap-4">
			<form class="form section">
				<label for="d-amount" class="label">Amount of eth (example: 0.001 eth)</label>
				<input type="number" name="dEthAmount" id="d-amount" class="input" />
				<button class="button" onclick={deposit}>Deposit</button>
			</form>
			<div class="divide"></div>

			<form class="form section">
				<label for="w-amount" class="label">Amount of eth (example: 0.001 eth)</label>
				<input type="number" name="wEthEmount" id="w-amount" class="input" />
				<button class="button" onclick={withdraw}>Withdraw</button>
			</form>
			<div class="divide"></div>
			<div class="section">
				<button class="button" onclick={refreshBalance}>Refresh balance</button>
				{#await balance}
					<p>Balance: Loading...</p>
				{:then b}
					<p>Balance: {b.toString()}</p>
				{/await}
			</div>
		</div>
	{/if}
</main>

<style lang="postcss">
	.section {
		@apply bg-slate-300 p-3 rounded;
	}
	.divide {
		@apply w-full h-0.5 bg-stone-950;
	}
	.form {
		@apply flex flex-col gap-2;
	}
	.input {
		@apply p-1 bg-stone-100 rounded-md;
	}
	.label {
		@apply text-xl font-semibold;
	}
	.button {
		@apply py-2 text-lg bg-stone-950 text-stone-100 w-fit font-semibold hover:opacity-80 rounded-md px-4;
	}
</style>
