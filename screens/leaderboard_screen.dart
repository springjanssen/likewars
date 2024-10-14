import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player_model.dart';
import '../auth/auth_provider.dart';

class RankingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.uid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ranking'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Fame'),
              Tab(text: 'Last Challenge'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFameRanking(currentUserId),
            _buildLastChallengeRanking(currentUserId),
          ],
        ),
      ),
    );
  }

  Widget _buildFameRanking(String? currentUserId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('players')
          .orderBy('fame', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final players = snapshot.data!.docs.map((doc) => PlayerModel.fromFirestore(doc)).toList();

        return ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            final isCurrentUser = player.id == currentUserId;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(player.photoURL),
              ),
              title: Text(
                player.displayName,
                style: isCurrentUser ? TextStyle(fontWeight: FontWeight.bold) : null,
              ),
              subtitle: Text(
                'Fame: ${player.fame} | Submitted Words: ${player.submissionHistory.length}',
              ),
              trailing: isCurrentUser ? Icon(Icons.star, color: Colors.yellow) : Text('#${index + 1}'),
            );
          },
        );
      },
    );
  }

  Widget _buildLastChallengeRanking(String? currentUserId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('challenges')
          .orderBy('endTime', descending: true)
          .limit(2)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final challengeData = snapshot.data!.docs;
        if (challengeData.length < 2) return Center(child: Text('No previous challenges found!'));

        final previousChallenge = challengeData[1].data() as Map<String, dynamic>;
        final wordSubmissions = previousChallenge['wordSubmissions'] as Map<String, dynamic>;

        final sortedSubmissions = wordSubmissions.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return _buildChallengeLeaderboardTable(sortedSubmissions, currentUserId);
      },
    );
  }

  Widget _buildChallengeLeaderboardTable(
      List<MapEntry<String, dynamic>> sortedSubmissions, String? currentUserId) {
    final totalPlayers = sortedSubmissions.length;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Rank')),
          DataColumn(label: Text('Word')),
          DataColumn(label: Text('Submissions')),
          DataColumn(label: Text('Fame')),
        ],
        rows: sortedSubmissions.map((entry) {
          final word = entry.key;
          final submissionCount = entry.value;
          final rank = sortedSubmissions.indexOf(entry) + 1;
          final isCurrentUser = word == currentUserId;
          final fame = _calculateFame(rank, totalPlayers);

          return DataRow(
            color: MaterialStateProperty.resolveWith<Color?>(
                (states) => isCurrentUser ? Colors.yellow.withOpacity(0.3) : null),
            cells: [
              DataCell(Text('#$rank')),
              DataCell(Text(word)),
              DataCell(Text(submissionCount.toString())),
              DataCell(Text(fame.toStringAsFixed(2))),
            ],
          );
        }).toList(),
      ),
    );
  }

  double _calculateFame(int rank, int totalPlayers) {
    return 100 * sqrt(totalPlayers) * (1 / rank) * (1 + (totalPlayers / 1000));
  }
}