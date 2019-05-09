---
layout: post
title: A Comparison Of Distributed Ledgers For Tokenization
author: darryl
date: '2018-10-07 02:58:07'
cover:  assets/images/cover-dlt.jpeg
navigation: True
class: post-template
tags: [blockchain]
---

If you’re like me, hearing the very word “blockchain” causes you to immediately tune out. Over-hyped as a solution to nearly every business problem imaginable, trying to wade through the noise is nearly a full time job. However, the technology can offer very powerful solutions to certain business problems. Tokenization is one such area where blockchain can have an enormous impact.

In this article we’ll look at the suitability of three popular public blockchain networks for tokenization use cases. Starting with an overview of tokenization and the business problems that it addresses, we’ll then present a high-level overview of blockchain and distributed ledger technology. We’ll be looking at three of the most popular blockchain networks, Stellar, Ripple, and Ethereum. We won’t be doing a deep technical dive into each blockchain network, instead we’ll evaluate each platform using a common set of high-level functional and non-functional tokenization requirements.

# Tokenization
Tokenization is a common model that most people have encountered even if they weren’t aware. Logging in to a website, credit card processing, loyalty points, even gift cards all leverage tokens.

In a nutshell, a token is a virtual representation of something else. That “something else” may be an asset such as a commodity, a payment token representing a credit card authorization, a loyalty reward point representing an alternative form of currency, even a login token so you don’t have to keep entering your username and password on your favorite websites. The token represents an exchange of something for a virtual representation of that thing. Credit card processing takes your credit card information and “tokenizes” it into a payment authorization. When you enter your username and password on a website, that information is turned into a token which is temporarily stored by your browser so you don’t have log in every time you click on a page. For loyalty points, the token is a point you earn which represents a virtual currency you can possibly use in the future.

## Benefits of Tokenization
Tokenization of payment card information and authorization credentials is very useful, although existing systems handle these business processes well.

Another type of tokenization is to take a real-world asset and represent it with a token. For example, a square foot of real estate could become a virtual token. If you buy shares in Google or Amazon you don’t want some of their office furniture, instead you get a share (a token) enabling you to own a part of the company. By tokenizing these real-world assets we now have the capability to trade them on a liquid market, allowing us to create new ways for companies and consumers to work together.

For these tokens there is a need to record ownership and other information about the token. Recently a new type of technology has emerged which is highly suited to this type of data. Known as “blockchain” or “distributed ledger technology”, it gives us the ability to record token information in a highly secure yet open manner.

# Defining Distributed Ledger Technology
The terms “blockchain” and “distributed ledger” are often used interchangeably, and while they’re related, they are technically not the same thing. A **blockchain** is an append-only, cryptographically linked data structure. This idea dates back to 1991, but was only recently used in a practical manner with the emergence of Bitcoin. A **distributed ledger** is a database of replicated and shared data stored across geographically separate nodes. Each node participates in a consensus protocol to ensure that all network participants agree on the contents of the database. When a blockchain data structure is used as the data storage mechanism within a distributed ledger, we now have what’s known as a **blockchain network** or **blockchain ledger**.

A blockchain network is often described as decentralized because it is replicated across many network participants, each of whom collaborate in its maintenance. The participants are responsible for agreeing on the contents of each new block in the blockchain, a process known as **consensus**. Some blockchain networks such as Bitcoin or Ethereum rely on what’s known as *proof of work* consensus. This is an energy intensive process known as “mining” in which nodes compete to solve computationally complex hashing problems. The winning node receives an incentive in the form of a token, either Bitcoin or Ether depending on the network. This consensus protocol is also by definition relatively slow, resulting in limited transaction speeds.

Alternative consensus protocols eliminate the mining process in favor of more energy efficient approaches. We will be comparing blockchain networks which use [Federated Byzantine Agreement](https://www.stellar.org/papers/stellar-consensus-protocol.pdf) (Stellar), [Proof of Stake](https://medium.com/coinmonks/blockchain-consensus-algorithm-the-proof-of-stake-slice-a4bda6658bbe) (hopefully coming soon to Ethereum), and [Proof of Correctness](https://ripple.com/build/reaching-consensus-xrp-ledger/) (Ripple).

In addition to being decentralized and collaborative, the information recorded to a blockchain is append-only, using cryptographic techniques which guarantee that once a transaction has been added to the ledger it cannot be modified. This property of immutability makes it simple to determine the provenance of information because participants can be sure information has not been changed after the fact. It’s why blockchains are sometimes described as systems of proof.

# Tokenization Requirements
Our primary requirement is that we need to be able to create a custom token on the blockchain network. This token should be usable as a payment method, support more complex payment flows such as those involving escrow, and has some way to convert to/from fiat currency such as USD.

In addition, we want to ensure that the platform is cost effective, highly secure, easy to integrate with, and supports the standard architectural “ilities” such as reliability, scalability, monitorability, etc.

Let’s detail out our functional and non-functional requirements:

## Functional Requirements

* **Ability to issue a custom asset.** The asset should be capable of being either privately or publicly traded, and have inflationary and/or deflationary characteristics.
* **Support for payment operations.** These should be low cost, and have the ability to attach a custom memo to each payment transaction.
* **Support for escrow operations.** We need the ability to place a payment into an escrow account to be released at a later point in time assuming all parties agree.
* **Support for multiple signature transactions.** A multi-signature transaction is one in which multiple accounts have to sign a transaction in order for it to be valid. In our case we need all transactions to be additionally signed by our asset ownership account to prevent abuse of the asset.
* **Ability to trade custom asset for other assets (including fiat currency).** For our asset to have real-world value, there may be a need to trade it for fiat currency. For example, an asset representing real estate may be sold for cash.

## Non-Functional Requirements

* **Minimal ongoing costs as volume increases.** We don’t want a situation where our costs become untenable as volume increases. Common issues here are with transaction fees, account minimum balances, and highly volatile blockchain native currencies.
* **Ease of development (SDKs, dev/test environments).** We need robust SDKs for popular languages/frameworks along with an easy way to test our applications.
* **Low operational overhead.** This is fairly subjective, but overall we would prefer a solution which requires a minimal amount of infrastructure, and offers high amounts of automation.

These requirements are just a baseline. Your solution will likely have far more to consider, but for our purposes of comparing blockchain networks these are what we’ll use.

In the next sections we’ll outline how various public blockchain networks supports our tokenization needs.

---

# Stellar
![STELLAR-logo](/content/images/2018/10/STELLAR-logo.png)

Designed as a global payments platform, [Stellar](https://stellar.org/) offers a number of compelling features. At a high level, it has a fast transaction rate, low energy consumption, and has support for custom assets, low cost transactions, federated identity, and a distributed exchange.

Let’s start by looking at how Stellar supports our functional requirements:
![Stellar-FR](/content/images/2018/10/Stellar-FR.png)

All of our primary functional requirements are well supported, with the exception of conversion to fiat. This is a limitation of many blockchain networks coupled with complex financial regulations. CoinBase is one of the few crypto exchanges with full regulatory support, but it only supports Bitcoin and Ethereum. Recently [Stronghold](https://stronghold.co/) has announced a USD exchange, so it’s likely that this situation will change for the better shortly.

Now let’s look at our non-functional requirements:
![Stellar-NFR](/content/images/2018/10/Stellar-NFR.png)

After having completed a number of POCs on the Stellar network, I’ve found it to be very easy to work with. The biggest drawback is the costs as the number of accounts increase. If we were to create accounts for every user in a 1 million user community, we need to come up with 2 million XLM, currently valued at $0.20/XLM, or $400,000. Were the value of XLM to rise, our costs rise accordingly.

A way to avoid this is to instead operate your solution with a [single custodial account](https://www.stellar.org/developers/guides/exchange.html) for all users. In this case, you need to manage all operations on behalf of users. Transactions need to indicate which user balances are affected, and you’re responsible for all key management. This lowers the upfront investment requirement, at the expense of increased development and security complexity.

From an enterprise architecture standpoint, Stellar is very easy to incorporate into a secure cloud infrastructure. If you choose to [operate your own anchor](https://www.stellar.org/developers/guides/anchor/index.html) (which you should if you issue a custom asset), Stellar provides all the necessary packages to stand up a simple single node server. Operating a highly available anchor is also straightforward, we’ll cover this process in a future article.

*For those interested in learning more about a secure approach to using Stellar, check out my Hashicorp Vault plugin for Stellar here: https://github.com/ParticipateCrypto/vault-plugin-stellar*

# Ripple
![ripple-logo](/content/images/2018/10/ripple-logo.svg)

[Ripple](https://ripple.com/) is very similar to Stellar on the surface. Ripple uses a different consensus protocol (proof of correctness), but similar to Stellar it is designed to handle payments so shares many of the same semantics.

Again, we start by looking at how Ripple supports our functional requirements:
![Ripple-FR](/content/images/2018/10/Ripple-FR.png)

Ripple meets most of our requirements in the same fashion as Stellar. However, Ripple does not support escrow payment operations using custom assets. If our tokenization solution requires escrow (think real estate, merchandise purchases, etc), then Ripple is not a good fit.

Now let’s look at our non-functional requirements:
![Ripple-NFR](/content/images/2018/10/Ripple-NFR.png)

Similar to Stellar, Ripple has a minimum balance on accounts which can quickly result in a cost issue. Assuming we need to create 1 million user accounts, this would cost 25 million XRP, and with XRP currently valued at $0.48 USD, corresponds to an upfront investment of $12,000,000. This is considerably higher than Stellar. Also note that Ripple does not have the ability to “merge” or “close” accounts, so it’s impossible to reclaim the XRP minimum balances in unused user accounts

Fortunately we can apply the same approach of using a single custodial account in order to eliminate this cost. In reality this is probably the only valid approach to working with Ripple if you need a large amount of user accounts.

On the ease of development front, Ripple has a robust JSON-RPC API as well as a mature Javascript SDK. However it is lacking support for SDKs in other languages such as Java or Python. This may or may not be an issue for you depending on your team’s skillset.

Integration of the Ripple network into your cloud architecture is fairly straightforward. You can operate one or more [rippled](https://developers.ripple.com/run-a-rippled-validator.html) servers, configured to either be stock or validator nodes. Similar to Stellar, if you’re relying on the Ripple network it’s in your best interest to operate your own rippled infrastructure.

# Ethereum
![ETHEREUM-LOGO_LANDSCAPE_Black_small](/content/images/2018/10/ETHEREUM-LOGO_LANDSCAPE_Black_small.png)

[Ethereum](https://ethereum.org/) is still the big player in this space. As one of the original blockchain networks which supported custom tokens and smart contracts, it has the most adoption in the tokenization space.

However, Ethereum currently relies on a proof of work consensus protocol which severely limits transaction speeds, and requires large amounts of energy to operate the network.

Ethereum smart contracts are different than Stellar and Ripple. They use a custom language called Solidity. These smart contract are far more powerful, and can be used to create fully featured distributed applications.

For our tokenization use cases, we don’t necessarily need all the capabilities of [Solidity](https://solidity.readthedocs.io/en/latest/). As long as we can issue a custom asset, make payments, and handle escrow, our smart contract requirements are met.
![Ethereum-FR](/content/images/2018/10/Ethereum-FR.png)

As we see above, Ethereum meets most of our functional requirements. The biggest drawback to using Ethereum is the transaction times. Payment operations can take multiple minutes to complete, depending on how much you’re willing to pay. This is unacceptable for most enterprise applications, and in this author’s humble opinion rules out Ethereum for our tokenization use cases. Ethereum may be shifting to a “proof of stake” consensus protocol primarily for this reason; if the shift results in much faster transaction times then Ethereum may be a good option.

For the sake of completeness, let’s look at how Ethereum meets our non-functional requirements:
![Ethereum-NFR](/content/images/2018/10/Ethereum-NFR.png)

Again Ethereum fails in the cost department. If we need the fastest possible transaction times (multiple seconds if not minutes), you may be paying fees of $0.05/transaction. However this price is highly variable. It’s nearly impossible to predict the transactional costs of your application.

Where Ethereum excels is in the developer community. It seems like everyone is developing on Ethereum, so there is a large selection of SDKs and APIs to choose from.

Many cloud providers offer pre-built Ethereum VM templates which allow you to quickly stand up your own nodes. For example, AWS has a CloudFormation template which deploys a cluster of Ethereum VMs in a docker cluster. Having these quickstarts is a further benefit of Ethereum over other blockchain networks.

# Other Options
Some other options that were considered:

## Hyperledger

Hyperledger, hosted by The Linux Foundation, is an open-source collaborative effort centered around blockchain technology.

Hyperledger is an umbrella project, and actually has five blockchain “frameworks”, commonly known as Sawtooth, Iroha, Fabric, Burrow, and Indy. These are private blockchains, meaning that you would need to stand up and operate your own network. Also, none of these projects support tokenization directly. Due to these factors Hyperledger is not a candidate for our tokenization use cases. While there are workarounds available, we instead choose to focus on blockchains which have native support for tokens.

In future articles we’ll look at other use cases such as supply chain management where Hyperledger is an excellent fit.

## Non-Blockchain Architecture

A question we should always ask is “why even use blockchain”? I would argue that for many use cases, the answer to this question would be that blockchain is not a suitable technology choice. Unless you have a need for a distributed, immutable, append-only data structure, you may be better served by an alternative architecture.

However, for tokenization use cases, blockchain can be a good fit. Ease of payments, immutable record of token ownership, exchange to fiat currency, and the ability to trade on exchanges are all benefits of using a blockchain network.

---
# Conclusion
After looking at how various blockchain networks are suited to tokenization use cases, Stellar is currently the best candidate. Other than the lack of an easy token to fiat conversion path, its combination of low-cost, fast transactions and robust development tooling makes it an excellent choice.

Ripple is a very close second. If you don’t need escrow operations for your custom token, it should be considered.

If Ethereum manages to reduce transaction fees and increase transaction times, it would be the obvious choice. But as it currently exists, choosing Ethereum would result in an expensive solution which would be unable to meet most end-user’s expectations for performance.

In a future article we’ll do a deeper technical dive into Stellar. Understanding how it meets enterprise requirements such as security, reliability, scalability, monitorability are important next steps before we commit to the platform.