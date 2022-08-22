# CoDeDANet

Community detection is an important task in social network analysis. It is generally based on the links of a static network, where groups of connected nodes can be found. Real-world problems, however, are often characterized by behavior that changes over time. In such cases, we need dynamic community detection algorithms because they better capture the underlying dynamics. Furthermore, the inclusion of node attributes provides a more robust approach since dynamic attribute values could also indicate changes in the communities. We propose an algorithm for COmmunity DEtection in Dynamic Attributed NETworks (CoDeDANet), which allows us to find groups in dynamic attributed networks using both the link and node information. In the first phase, based on spectral clustering, the attributes' importance is optimized in a setting that joins the nodes' features with a topological structure. In a second phase, tensors are used to consider not only current but also past information. The algorithm was tested on four synthetic networks and one real-world social network. The results show that CoDeDANet outperforms the other state-of-the-art community detection algorithms.

The file "Data description" describes the data folder used in our paper.

The code to reproduce the data, and the code for the algorithm, will be available in future versions.
