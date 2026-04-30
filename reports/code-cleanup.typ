#show link: set text(fill: blue)

= Making the TokenSmith repository more maintainable

Code link: #link("https://github.com/horo-fox/TokenSmith"), but you can
see the diff here: #link("https://github.com/georgia-tech-db/TokenSmith/compare/main...horo-fox:TokenSmith:code-cleanup").

There's always more software engineering practices to follow, so I
decided that the best project for me, considering I am familiar with
the Python ecosystem, is to help improve the setup for this repository.

Copying over the list of potential improvements from my initial
proposal (with better formatting now!), here's some possibilities:
 - allow substituting out ollama for llama.cpp
 - alternatively find a precompiled llama.cpp on PyPI
 - either of the above would allow users not to have anaconda installed
 - add a linter
 - switch from Black to Ruff's autoformatter
 - add a typechecker
 - have a lockfile
 - clean up unnecessary files, like `.DS_Store`
 - update the GitHub Actions configuration to run everything
 - improve tests

Some of these are vaguer than others, but generally they should help
future contributors by standardizing more.


== No longer requiring Anaconda

Anaconda is required for the compiled `llama_cpp`. However, I am not
convinced that is necessary. The ideal would be to switch away, because
Anaconda is gigantic -- ~1GB installer via homebrew! -- and an extra
thing to install and slow: `make build` takes 150.26 seconds. It's also
sometimes confusing, as I ran into an issue while timing setup where
`conda activate tokensmith` was telling me to run `conda init`, but I
had already done that. (the issue was that it was initializing Anaconda
for the wrong shell!)

=== Switching to a precompiled `llama.cpp` on PyPI

Unfortunately, it seems that Python wheels (precompiled packages) are
not advanced enough to support the large array of possibilities that
depend e.g. on your GPU. I don't think this is possible.

=== Shelling out to a precompiled provider

It seems possible to use Ollama. Essentially, anything with a
`from llama_cpp import Llama` would be replaced with `import ollama`.
However, I'm not yet convinced this is the easiest alternative.
Regardless, it's likely easier to install than worrying about anaconda
and a Makefile and having to compile llama.cpp.

I think it would be simple to catch `ImportError` and try using
the `ollama` instead. This would mean that if someone wants, they
could use `llama.cpp`, but they could also avoid having to compile
anything. This should also check there's a running server, otherwise
the program will error out at some point later which is annoying.

Additionally, I think the model names differ between the files and what
we can provide to `ollama`... I'm not sure if the best solution is an
extra configuration key.

=== One more benefit: lockfile

It looks like there's a #link("https://github.com/conda/conda-lock")[conda-lock]
project that provides lockfiles for anaconda. However, it appears any
`conda create` would need to then be `conda-lock install`, which is not
great.

Instead, by allowing the project to be installed via `uv`, I've
automatically made lockfiles work.

=== Linter + autoformatter

This doesn't seem very hard. I'll need to format my final report
weirdly, because while I could just do this and provide the diff, the
changes will very easily go out of sync! Instead, I should probably
provide commands to do so and provide a branch without these changes.

== Challenges and observations

I didn't run into that many challenges as I made very limited changes,
but here's a few observations I made:
 - there's a deprecation warning saying to replace
   `DoclingParseV2DocumentBackend` with `DoclingParseDocumentBackend`
 - for some reason, `TokenSmith-Frontend` didn't seem to work with
   Safari (but this is probably just a skill issue...)

== Next steps

I should do more of the improvements and come up with some more.
Additionally, I should probably get some feedback on what sort of
code quality tools are even nice; maybe our instructor has some set of
preferred tooling.

#pagebreak()

= Appendix: learning episode questions

Question 1: What are some common logical optimizations?

Correct textbook chunks:
 - We can improve query-evaluation efficiency by reducing the number of temporary files that are produced. We achieve this reduction by combining several relational operations into a pipeline of operations, in which the results of one operation are passed along to the next operation in the pipeline. Evaluation as just described is called pipelined evaluation . For example, consider the expression (Π a 1 , a 2 ( r ⋈ s )). If materialization were applied, evaluation would involve creating a temporary relation to hold the result of the join and then reading back in the result to perform the projection. These operations can be combined: When the join operation generates a tuple of its result, it passes that tuple immediately to the project operation for processing. By combining the join and the projection, we avoid creating the intermediate result and instead create the final result directly. Page 726 Creating a pipeline of operations can provide two benefits: 1. It eliminates the cost of reading and writing temporary relations, reducing the cost of query evaluation. Note that the cost formulae that we saw earlier for each operation included the cost of reading the result from disk. If the input to an operator o i is pipelined from a preceding operator Oj , the cost of o i should not include the cost of reading the input from disk; the cost formulae that we saw earlier can be modified accordingly. 2. It can start generating query results quickly, if the root operator of a query-evaluation plan is combined in a pipeline with its inputs. This can be quite useful if the results are displayed to a user as they are generated, since otherwise there may be a long delay before the user sees any query results.
 - When a batch of queries are submitted together, a query optimizer can potentially exploit common subexpressions between the different queries, evaluating them once and reusing them where required. Complex queries may in fact have subexpressions repeated in different parts of the query, which can be similarly exploited to reduce query evaluation cost. Such optimization is known as optimization . Page 786 Common subexpression elimination optimizes subexpressions shared by different expressions in a program by computing and storing the result and reusing it wherever the subexpression occurs. Common subexpression elimination is a standard optimization applied on arithmetic expressions by programming-language compilers. Exploiting common subexpressions among evaluation plans chosen for each of a batch of queries is just as useful in database query evaluation, and is implemented by some databases. However, multiquery optimization can do even better in some cases: A query typically has more than one evaluation plan, and a judiciously chosen set of query evaluation plans for the queries may provide for a greater sharing and lesser cost than that afforded by choosing the lowest cost evaluation plan for each query. More details on multiquery optimization may be found in references cited in the bibliographical notes. Sharing of relation scans between queries is another limited form of multiquery optimization that is implemented in some databases. The shared-scan optimization works as follows: Instead of reading the relation repeatedly from disk, once for each query that needs to scan a relation, data are read once from disk, and pipelined to each of the queries. The shared-scan optimization is particularly useful when multiple queries perform a scan on a single large relation (typically a 'fact table').

Question 2: What differentiates these optimizations from physical query optimizations?

Correct testbook chunk: (kind of)
 - . Scheduling of independent operations in parallel on different nodes is not considered at this stage. Partitioning of inputs and intermediate results is taken into consideration when estimating the cost of a query plan. Existing techniques for query optimization have been extended by considering partitioning as a physical property, in addition to physical properties such as sort orders that are already taken into account when choosing a sequential query plan. Just as sort operators are added to a query plan to get a desired sort order, exchange operators are added to get the desired partitioning property. The cost model used in practice is typically a resource consumption model, which we saw earlier. Although response-time cost models offer better estimates of query execution time, the cost of query optimization is higher when using a response-time cost - model compared to the cost of optimization when using a resource-consumption cost model. References providing more information on the response-time cost model may be found in the Further Reading section at the end of the chapter. Page 1068 Yet another dimension of optimization is the design of physical-storage organization to speed up queries. For example, a relation can be stored partitioned on any of several different attributes, and it may even be replicated and replicas can be stored partitioned on different attributes. For example, a relation r ( A , B , C ) could be stored partitioned on A, and a replica could be partitioned on B . The query optimizer chooses the replica that is best suited for the query. The optimal physical organization differs for different queries. The database administrator must choose a physical organization that appears to be good for the expected mix of database queries.

Question 3: What sort of physical organizations are there to choose from?

Correct textbook chunk:
 - So far, we have studied how records are represented in a file structure. A relation is a set of records. Given a set of records, the next question is how to organize them in a file. Several of the possible ways of organizing records in files are: - Heap file organization . Any record can be placed anywhere in the file where there is space for the record. There is no ordering of records. Typically, there is either a single file or a set of files for each relation. Heap file organization is discussed in Section 13.3.1. - Sequential file organization . Records are stored in sequential order, according to the value of a 'search key' of each record. Section 13.3.2 describes this organization. - Multitable clustering file organization : Generally, a separate file or set of files is used to store the records of each relation. However, in a multitable clustering file organization , records of several different relations are stored in the same file, and in fact in the same block within a file, to reduce the cost of certain join - operations. Section 13.3.3 describes the multitable clustering file organization. - B + -tree file organization . The traditional sequential file organization described in Section 13.3.2 does support ordered access even if there are insert, delete, and update operations, which may change the ordering of records. However, in the face of a large number of such operations, efficiency of ordered access suffers. We study another way of organizing records, called the B + tree file organization, in Section 14.4.1. The B + -tree file organization is related to the B + -tree index structure described in that chapter and can provide efficient ordered access to records even if there are a large number of insert, delete, or update operations. Further, it supports very efficient access to specific records, based on the search key. - Hashing file organization . A hash function is computed on some attribute of each record

Question 4: What are the most popular hashing algorithms for databases?

Correct textbook chunk:
 - The worst possible hash function maps all search-key values to the same bucket. Such a function is undesirable because all the records have to be kept in the same bucket. A lookup has to examine every such record to find the one desired. An ideal hash function distributes the stored keys uniformly across all the buckets, so that every bucket has the same number of records. Since we do not know at design time precisely which search-key values will be stored in the file, we want to choose a hash function that assigns search-key values to buckets in such a way that the distribution has these qualities: - The distribution is uniform. That is, the hash function assigns each bucket the same number of search-key values from the set of all possible search-key values. - The distribution is random . That is, in the average case, each bucket will have nearly the same number of values assigned to it, regardless of the actual distribution of search-key values. More precisely, the hash value will not be correlated to any externally visible ordering on the search-key values, such as alphabetic ordering or ordering by the length of the search keys; the hash function will appear to be random. As an illustration of these principles, let us choose a hash function for the instructor file using the search key Page 1193 dept\_name. The hash function that we choose must have the desirable properties not only on the example instructor file that we have been using, but also on an instructor file of realistic size for a large university with many departments. Assume that we decide to have 26 buckets, and we define a hash function that maps names beginning with the i th letter of the alphabet to the i th bucket. This hash function has the virtue of simplicity, but it fails to provide a uniform distribution, since we expect more names to begin with such letters as B and R than Q and X , for example. Now suppose that we want a hash function on the search key salary

Question 5: What's the single most effective optimization?

Correct textbook chunk: (they all kind of sucked)
 - We can tune the indices in a database system to improve performance. If queries are the bottleneck, we can often speed them up by creating appropriate indices on relations. If updates are the bottleneck, there may be too many indices, which have to be updated when the relations are updated. Removing indices may speed up certain updates. The choice of the type of index also is important. Some database systems support different kinds of indices, such as hash indices, B + -tree indices, and write-optimized indices such as LSM trees (Section 24.2). If range queries are common, B + -tree indices are preferable to hash indices. If the system has a very high write load, but a relatively low read load, write-optimized LSM tree indices may be preferable to B + -tree indices. Whether to make an index a clustered index is another tunable parameter. Only one index on a relation can be made clustered, by storing the relation sorted on the index attributes. Generally, the index that benefits the greatest number of queries and updates should be made clustered. To help identify what indices to create, and which index (if any) on each relation should be clustered, most commercial database systems provide tuning wizards; these are described in more detail in Section 25.1.4.4. These tools use the past history of queries and updates (called the workload ) to estimate the effects of various indices on the execution time of the queries and updates in the workload. Recommendations on what indices to create are based on these estimates.
